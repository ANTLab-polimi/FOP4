/*
 * Copyright 2017-present Open Networking Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <core.p4>
#include <v1model.p4>

#define MAX_PORTS 255

const bit<16> ETH_TYPE_IPV4 = 0x800;

const bit<8> IP_TYPE_TCP = 0x06;
const bit<8> IP_TYPE_UDP = 0x11;

typedef bit<9> port_t;
const port_t CPU_PORT = 255;

//------------------------------------------------------------------------------
// HEADERS
//------------------------------------------------------------------------------

header ethernet_t {
    bit<48> dst_addr;
    bit<48> src_addr;
    bit<16> ether_type;
}

header my_tunnel_t {
    bit<16> proto_id;
    bit<32> tun_id;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> len;
    bit<16> identification;
    bit<3>  flags;
    bit<13> frag_offset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
}


// Packet-in header. Prepended to packets sent to the controller and used to
// carry the original ingress port where the packet was received.
@controller_header("packet_in")
header packet_in_header_t {
    bit<16> ingress_port;
}

// Packet-out header. Prepended to packets received by the controller and used
// to tell the switch on which port this packet should be forwarded.
@controller_header("packet_out")
header packet_out_header_t {
    bit<16> egress_port;
}

// For convenience we collect all headers under the same struct.
struct headers_t {
    ethernet_t ethernet;
    ipv4_t ipv4;
    tcp_t tcp;
    udp_t udp;
    packet_out_header_t packet_out;
    packet_in_header_t packet_in;
}

// Metadata can be used to carry information from one table to another.
struct metadata_t {
    bit<16> l4_srcPort;
    bit<16> l4_dstPort;
    bit<16> current_output;
    bit<32> hash_val;
    bit<16> tcpLength;
    bit<1>  no_l2_fwd;
}

//------------------------------------------------------------------------------
// PARSER
//------------------------------------------------------------------------------

parser c_parser(packet_in packet,
                  out headers_t hdr,
                  inout metadata_t meta,
                  inout standard_metadata_t standard_metadata) {

    // A P4 parser is described as a state machine, with initial state "start"
    // and final one "accept". Each intermediate state can specify the next
    // state by using a select statement over the header fields extracted.
    state start {
        transition select(standard_metadata.ingress_port) {
            CPU_PORT: parse_packet_out;
            default: parse_ethernet;
        }
    }

    state parse_packet_out {
        packet.extract(hdr.packet_out);
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETH_TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }


    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.tcpLength = hdr.ipv4.len - 16w20;
        transition select(hdr.ipv4.protocol) {
            IP_TYPE_TCP: parse_tcp;
            IP_TYPE_UDP: parse_udp;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        meta.l4_srcPort = hdr.tcp.srcPort;
        meta.l4_dstPort = hdr.tcp.dstPort;
        transition accept;
    }

    state parse_udp {
        packet.extract(hdr.udp);
        meta.l4_srcPort = hdr.udp.srcPort;
        meta.l4_dstPort = hdr.udp.dstPort;
        transition accept;
    }
}

//------------------------------------------------------------------------------
// LOAD BALANCER CONTROL BLOCK
//------------------------------------------------------------------------------

control LoadBalancer(inout headers_t hdr,
                        inout metadata_t meta,
                        inout standard_metadata_t standard_metadata) {

    // These registers are used for round-robin load balancing
    register<bit<16>>(1) load_balancer; // Current state of the load balancer
    register<bit<16>>(16384) state; // State per flow



    action hash_header() {
        // TODO: Be consistent on hashing in both directions
        hash(meta.hash_val,
                HashAlgorithm.crc16,
                10w0,
                {hdr.ipv4.src_addr,
                    hdr.tcp.srcPort,
                    hdr.ipv4.dst_addr,
                    hdr.tcp.dstPort},
                10w1023);
    }

    action set_no_l2_fwd() {
        meta.no_l2_fwd = 0x1;
    }

    action _drop() {
        mark_to_drop();
    }

    action set_nhop(bit<48> nhop_dmac, bit<32> nhop_ipv4, port_t port){
        hdr.ethernet.dst_addr = nhop_dmac;
        hdr.ipv4.dst_addr = nhop_ipv4;
        //standard_metadata.egress_spec = port;
    }

    action substitute_src(bit<48> src_mac, bit<32> src_ipv4, port_t port) {
        hdr.ethernet.src_addr = src_mac;
        hdr.ipv4.src_addr = src_ipv4;
    }


    direct_counter(CounterType.packets_and_bytes) http_load_balancer_counter;
    table http_load_balancer {
        key = {
            hdr.ipv4.dst_addr       : exact;
            meta.current_output     : ternary;
        }
        actions = {
            set_nhop;
            _drop;
            NoAction;
        }
        default_action = NoAction();
        counters = http_load_balancer_counter;
        size = 2; // TODO: modify depending on the amount of destination of the load balancer
    }

    direct_counter(CounterType.packets_and_bytes) other_direction_counter;
    table other_direction {
        key = {
            hdr.ipv4.src_addr: exact;
        }
        actions = {
            _drop;
            substitute_src;
        }
        counters = other_direction_counter;
        size = 1024;
    }



    apply{
        bit<16> temp;
        bit<16> state_temp;

        // Just to make it more simple, only apply the load balancer to all TCP traffic
        if (hdr.tcp.isValid()) {
            // Calculate the hash of the header to get the output port on the load balancer
            hash_header();
            @atomic {
            if(!other_direction.apply().hit){

                // Read the current state correspondent to the value store in the state variable
                state.read(state_temp, meta.hash_val);

                // If the state is 0 then no entry stored
                // TODO: it could be better to check if a SYN is received to decide when to increase the load_balancer reg.
                if(state_temp == 0) {
                    // Need to calculate the output port of the load balancer

                        // should be indexed by dst IP
                        load_balancer.read(temp, 0x00);
                        temp = temp + 1;
                        load_balancer.write(0x00, temp);
                        state.write(meta.hash_val, temp);
                }
                state.read(meta.current_output, meta.hash_val);

                http_load_balancer.apply();
                // TODO: it should also check when FIN packet is received so we can reset the state register (not necessary if we check the SYN)
            }
        }

        }
    }

}


//------------------------------------------------------------------------------
// INGRESS PIPELINE
//------------------------------------------------------------------------------

control c_ingress(inout headers_t hdr,
                    inout metadata_t meta,
                    inout standard_metadata_t standard_metadata) {

    // We use these counters to count packets/bytes received/sent on each port.
    // For each counter we instantiate a number of cells equal to MAX_PORTS.
    counter(MAX_PORTS, CounterType.packets_and_bytes) tx_port_counter;
    counter(MAX_PORTS, CounterType.packets_and_bytes) rx_port_counter;
    

// -------------------------------------- ACTIONS -----------------------------------------------------
    action set_out_port(port_t port) {
        // Specifies the output port for this packet by setting the
        // corresponding metadata.
        standard_metadata.egress_spec = port;
    }

    action send_to_cpu() {
        standard_metadata.egress_spec = CPU_PORT;
        // Packets sent to the controller needs to be prepended with the
        // packet-in header. By setting it valid we make sure it will be
        // deparsed on the wire (see c_deparser).
        hdr.packet_in.setValid();
        hdr.packet_in.ingress_port = (bit<16>)(standard_metadata.ingress_port);
    }

    action _drop() {
        mark_to_drop();
    }

    // Table counter used to count packets and bytes matched by each entry of
    // t_l2_fwd table.
    direct_counter(CounterType.packets_and_bytes) l2_fwd_counter;
    table t_l2_fwd {
        key = {
            standard_metadata.ingress_port  : ternary;
            hdr.ethernet.dst_addr           : ternary;
            hdr.ethernet.src_addr           : ternary;
            hdr.ethernet.ether_type         : ternary;
        }
        actions = {
            set_out_port;
            send_to_cpu;
            _drop;
            NoAction;
        }
        default_action = NoAction();
        counters = l2_fwd_counter;
    }

    LoadBalancer() loadbalancer;

    apply {
        if (standard_metadata.ingress_port == CPU_PORT) {
            // Packet received from CPU_PORT, this is a packet-out sent by the
            // controller. Skip table processing, set the egress port as
            // requested by the controller (packet_out header) and remove the
            // packet_out header.
            standard_metadata.egress_spec = (bit<9>)(hdr.packet_out.egress_port);
            hdr.packet_out.setInvalid();
        } else {
            //Apply the control loadbalancer
            loadbalancer.apply(hdr, meta, standard_metadata);

            // Packet received from data plane port.
            // Applies table t_l3_fwd to the packet.
            t_l2_fwd.apply();
            //meta.current_number = temp;
        }
        if (standard_metadata.egress_spec < MAX_PORTS) {
            tx_port_counter.count((bit<32>) standard_metadata.egress_spec);
        }
        if (standard_metadata.ingress_port < MAX_PORTS) {
            rx_port_counter.count((bit<32>) standard_metadata.ingress_port);
        }
     }
}

//------------------------------------------------------------------------------
// EGRESS PIPELINE
//------------------------------------------------------------------------------

control c_egress(inout headers_t hdr,
                 inout metadata_t meta,
                 inout standard_metadata_t standard_metadata) {
    apply {

    }
}

//------------------------------------------------------------------------------
// CHECKSUM HANDLING
//------------------------------------------------------------------------------

control c_verify_checksum(inout headers_t hdr, inout metadata_t meta) {
    apply {
        // Nothing to do here, we assume checksum is always correct.
    }
}

control c_compute_checksum(inout headers_t hdr, inout metadata_t meta) {
    apply {
        // Compute new checksum, the packet can be modified if the load balancer has modified the dst addresses
        update_checksum(
            hdr.ipv4.isValid(),
            {
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.len,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.frag_offset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.src_addr,
                hdr.ipv4.dst_addr
            },
            hdr.ipv4.hdr_checksum,
            HashAlgorithm.csum16
        );
        update_checksum_with_payload(
            hdr.tcp.isValid(),
            {
                hdr.ipv4.src_addr,
                hdr.ipv4.dst_addr,
                8w0,
                hdr.ipv4.protocol,
                meta.tcpLength,
                hdr.tcp.srcPort,
                hdr.tcp.dstPort,
                hdr.tcp.seqNo,
                hdr.tcp.ackNo,
                hdr.tcp.dataOffset,
                hdr.tcp.res,
                hdr.tcp.flags,
                hdr.tcp.window,
                hdr.tcp.urgentPtr
            },
            hdr.tcp.checksum,
            HashAlgorithm.csum16
        );
    }
}

//------------------------------------------------------------------------------
// DEPARSER
//------------------------------------------------------------------------------

control c_deparser(packet_out packet, in headers_t hdr) {
    apply {
        // Emit headers on the wire in the following order.
        // Only valid headers are emitted.
        packet.emit(hdr.packet_in);
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
    }
}

//------------------------------------------------------------------------------
// SWITCH INSTANTIATION
//------------------------------------------------------------------------------

V1Switch(c_parser(),
         c_verify_checksum(),
         c_ingress(),
         c_egress(),
         c_compute_checksum(),
         c_deparser()) main;
