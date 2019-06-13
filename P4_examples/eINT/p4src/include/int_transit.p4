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

/* -*- P4_16 -*- */
#ifndef __INT_TRANSIT__
#define __INT_TRANSIT__
control process_int_transit (
    inout headers_t hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    action init_metadata(switch_id_t switch_id) {
        local_metadata.int_meta.transit = _TRUE;
        local_metadata.int_meta.switch_id = switch_id;
    }

    @hidden
    action int_set_header_0() { //switch_id
        hdr.int_switch_id.setValid();
        hdr.int_switch_id.switch_id = local_metadata.int_meta.switch_id;
    }
    @hidden
    action int_set_header_1() { //level1_port_id
        hdr.int_level1_port_ids.setValid();
        hdr.int_level1_port_ids.ingress_port_id = (bit<16>) standard_metadata.ingress_port;
        hdr.int_level1_port_ids.egress_port_id = (bit<16>) standard_metadata.egress_port;
    }
    @hidden
    action int_set_header_2() { //hop_latency
        hdr.int_hop_latency.setValid();
        hdr.int_hop_latency.hop_latency = (bit<32>) standard_metadata.egress_global_timestamp - (bit<32>) standard_metadata.ingress_global_timestamp;
    }
    @hidden
    action int_set_header_3() { //q_occupancy
        // TODO: Support egress queue ID
        hdr.int_q_occupancy.setValid();
        hdr.int_q_occupancy.q_id =
        0;
        // (bit<8>) standard_metadata.egress_qid;
        hdr.int_q_occupancy.q_occupancy =
        (bit<24>) standard_metadata.deq_qdepth;
    }
    @hidden
    action int_set_header_4() { //ingress_tstamp
        hdr.int_ingress_tstamp.setValid();
        hdr.int_ingress_tstamp.ingress_tstamp =
        (bit<32>) standard_metadata.ingress_global_timestamp;
    }
    @hidden
    action int_set_header_5() { //egress_timestamp
        hdr.int_egress_tstamp.setValid();
        hdr.int_egress_tstamp.egress_tstamp =
        (bit<32>) standard_metadata.egress_global_timestamp;
    }
    @hidden
    action int_set_header_6() { //level2_port_id
        hdr.int_level2_port_ids.setValid();
        // level2_port_id indicates Logical port ID
        hdr.int_level2_port_ids.ingress_port_id = (bit<32>) standard_metadata.ingress_port;
        hdr.int_level2_port_ids.egress_port_id = (bit<32>) standard_metadata.egress_port;
     }
    @hidden
    action int_set_header_7() { //egress_port_tx_utilization
        // TODO: implement tx utilization support in BMv2
        hdr.int_egress_tx_util.setValid();
        hdr.int_egress_tx_util.egress_port_tx_util =
        // (bit<32>) queueing_metadata.tx_utilization;
        0;
    }

    // Actions to keep track of the new metadata added.
    @hidden
    action add_1() {
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + 1;
        local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + 4;
    }

    @hidden
    action add_2() {
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + 2;
        local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + 8;
    }

    @hidden
    action add_3() {
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + 3;
        local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + 12;
    }

    @hidden
    action add_4() {
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + 4;
       local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + 16;
    }

    @hidden
    action add_5() {
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + 5;
        local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + 20;
    }

     /* action function for bits 0-3 combinations, 0 is msb, 3 is lsb */
     /* Each bit set indicates that corresponding INT header should be added */
    @hidden
     action int_set_header_0003_i0() {
     }
    @hidden
     action int_set_header_0003_i1() {
        int_set_header_3();
        add_1();
    }
    @hidden
    action int_set_header_0003_i2() {
        int_set_header_2();
        add_1();
    }
    @hidden
    action int_set_header_0003_i3() {
        int_set_header_3();
        int_set_header_2();
        add_2();
    }
    @hidden
    action int_set_header_0003_i4() {
        int_set_header_1();
        add_1();
    }
    @hidden
    action int_set_header_0003_i5() {
        int_set_header_3();
        int_set_header_1();
        add_2();
    }
    @hidden
    action int_set_header_0003_i6() {
        int_set_header_2();
        int_set_header_1();
        add_2();
    }
    @hidden
    action int_set_header_0003_i7() {
        int_set_header_3();
        int_set_header_2();
        int_set_header_1();
        add_3();
    }
    @hidden
    action int_set_header_0003_i8() {
        int_set_header_0();
        add_1();
    }
    @hidden
    action int_set_header_0003_i9() {
        int_set_header_3();
        int_set_header_0();
        add_2();
    }
    @hidden
    action int_set_header_0003_i10() {
        int_set_header_2();
        int_set_header_0();
        add_2();
    }
    @hidden
    action int_set_header_0003_i11() {
        int_set_header_3();
        int_set_header_2();
        int_set_header_0();
        add_3();
    }
    @hidden
    action int_set_header_0003_i12() {
        int_set_header_1();
        int_set_header_0();
        add_2();
    }
    @hidden
    action int_set_header_0003_i13() {
        int_set_header_3();
        int_set_header_1();
        int_set_header_0();
        add_3();
    }
    @hidden
    action int_set_header_0003_i14() {
        int_set_header_2();
        int_set_header_1();
        int_set_header_0();
        add_3();
    }
    @hidden
    action int_set_header_0003_i15() {
        int_set_header_3();
        int_set_header_2();
        int_set_header_1();
        int_set_header_0();
        add_4();
    }

     /* action function for bits 4-7 combinations, 4 is msb, 7 is lsb */
    @hidden
    action int_set_header_0407_i0() {
    }
    @hidden
    action int_set_header_0407_i1() {
        int_set_header_7();
        add_1();
    }
    @hidden
    action int_set_header_0407_i2() {
        int_set_header_6();
        add_2();
    }
    @hidden
    action int_set_header_0407_i3() {
        int_set_header_7();
        int_set_header_6();
        add_3();
    }
    @hidden
    action int_set_header_0407_i4() {
        int_set_header_5();
        add_1();
    }
    @hidden
    action int_set_header_0407_i5() {
        int_set_header_7();
        int_set_header_5();
        add_2();
    }
    @hidden
    action int_set_header_0407_i6() {
        int_set_header_6();
        int_set_header_5();
        add_3();
    }
    @hidden
    action int_set_header_0407_i7() {
        int_set_header_7();
        int_set_header_6();
        int_set_header_5();
        add_4();
    }
    @hidden
    action int_set_header_0407_i8() {
        int_set_header_4();
        add_1();
    }
    @hidden
    action int_set_header_0407_i9() {
        int_set_header_7();
        int_set_header_4();
        add_2();
    }
    @hidden
    action int_set_header_0407_i10() {
        int_set_header_6();
        int_set_header_4();
        add_3();
    }
    @hidden
    action int_set_header_0407_i11() {
        int_set_header_7();
        int_set_header_6();
        int_set_header_4();
        add_4();
    }
    @hidden
    action int_set_header_0407_i12() {
        int_set_header_5();
        int_set_header_4();
        add_2();
    }
    @hidden
    action int_set_header_0407_i13() {
        int_set_header_7();
        int_set_header_5();
        int_set_header_4();
        add_3();
    }
    @hidden
    action int_set_header_0407_i14() {
        int_set_header_6();
        int_set_header_5();
        int_set_header_4();
        add_4();
    }
    @hidden
    action int_set_header_0407_i15() {
        int_set_header_7();
        int_set_header_6();
        int_set_header_5();
        int_set_header_4();
        add_5();
    }

    // Default action used to set switch ID.
    table tb_int_insert {
        // We don't really need a key here, however we add a dummy one as a
        // workaround to ONOS inability to properly support default actions.
        key = {
            hdr.int_header.isValid(): exact @name("int_is_valid");
        }
        actions = {
            init_metadata;
            @defaultonly nop;
        }
        const default_action = nop();
        size = 1;
    }

    /* Table to process instruction bits 0-3 */
    @hidden
    table tb_int_inst_0003 {
        key = {
            hdr.int_header.instruction_mask_0003 : exact;
        }
        actions = {
            int_set_header_0003_i0;
            int_set_header_0003_i1;
            int_set_header_0003_i2;
            int_set_header_0003_i3;
            int_set_header_0003_i4;
            int_set_header_0003_i5;
            int_set_header_0003_i6;
            int_set_header_0003_i7;
            int_set_header_0003_i8;
            int_set_header_0003_i9;
            int_set_header_0003_i10;
            int_set_header_0003_i11;
            int_set_header_0003_i12;
            int_set_header_0003_i13;
            int_set_header_0003_i14;
            int_set_header_0003_i15;
        }
        const entries = {
            (0x0) : int_set_header_0003_i0();
            (0x1) : int_set_header_0003_i1();
            (0x2) : int_set_header_0003_i2();
            (0x3) : int_set_header_0003_i3();
            (0x4) : int_set_header_0003_i4();
            (0x5) : int_set_header_0003_i5();
            (0x6) : int_set_header_0003_i6();
            (0x7) : int_set_header_0003_i7();
            (0x8) : int_set_header_0003_i8();
            (0x9) : int_set_header_0003_i9();
            (0xA) : int_set_header_0003_i10();
            (0xB) : int_set_header_0003_i11();
            (0xC) : int_set_header_0003_i12();
            (0xD) : int_set_header_0003_i13();
            (0xE) : int_set_header_0003_i14();
            (0xF) : int_set_header_0003_i15();
        }
    }

    /* Table to process instruction bits 4-7 */
    @hidden
    table tb_int_inst_0407 {
        key = {
            hdr.int_header.instruction_mask_0407 : exact;
        }
        actions = {
            int_set_header_0407_i0;
            int_set_header_0407_i1;
            int_set_header_0407_i2;
            int_set_header_0407_i3;
            int_set_header_0407_i4;
            int_set_header_0407_i5;
            int_set_header_0407_i6;
            int_set_header_0407_i7;
            int_set_header_0407_i8;
            int_set_header_0407_i9;
            int_set_header_0407_i10;
            int_set_header_0407_i11;
            int_set_header_0407_i12;
            int_set_header_0407_i13;
            int_set_header_0407_i14;
            int_set_header_0407_i15;
        }
        const entries = {
            (0x0) : int_set_header_0407_i0();
            (0x1) : int_set_header_0407_i1();
            (0x2) : int_set_header_0407_i2();
            (0x3) : int_set_header_0407_i3();
            (0x4) : int_set_header_0407_i4();
            (0x5) : int_set_header_0407_i5();
            (0x6) : int_set_header_0407_i6();
            (0x7) : int_set_header_0407_i7();
            (0x8) : int_set_header_0407_i8();
            (0x9) : int_set_header_0407_i9();
            (0xA) : int_set_header_0407_i10();
            (0xB) : int_set_header_0407_i11();
            (0xC) : int_set_header_0407_i12();
            (0xD) : int_set_header_0407_i13();
            (0xE) : int_set_header_0407_i14();
            (0xF) : int_set_header_0407_i15();
        }
    }

    @hidden
    action add_0_extra() {
    }
    @hidden
    action add_1_extra() {
        hdr.extra_data[0].setValid();
        hdr.extra_data[0].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_2_extra() {
        add_1_extra();
        hdr.extra_data[1].setValid();
        hdr.extra_data[1].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_3_extra() {
        add_2_extra();
        hdr.extra_data[2].setValid();
        hdr.extra_data[2].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_4_extra() {
        add_3_extra();
        hdr.extra_data[3].setValid();
        hdr.extra_data[3].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_5_extra() {
        add_4_extra();
        hdr.extra_data[4].setValid();
        hdr.extra_data[4].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_6_extra() {
        add_5_extra();
        hdr.extra_data[5].setValid();
        hdr.extra_data[5].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_7_extra() {
        add_6_extra();
        hdr.extra_data[6].setValid();
        hdr.extra_data[6].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_8_extra() {
        add_7_extra();
        hdr.extra_data[7].setValid();
        hdr.extra_data[7].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_9_extra() {
        add_8_extra();
        hdr.extra_data[8].setValid();
        hdr.extra_data[8].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_10_extra() {
        add_9_extra();
        hdr.extra_data[9].setValid();
        hdr.extra_data[9].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_11_extra() {
        add_10_extra();
        hdr.extra_data[10].setValid();
        hdr.extra_data[10].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_12_extra() {
        add_11_extra();
        hdr.extra_data[11].setValid();
        hdr.extra_data[11].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_13_extra() {
        add_12_extra();
        hdr.extra_data[12].setValid();
        hdr.extra_data[12].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_14_extra() {
        add_13_extra();
        hdr.extra_data[13].setValid();
        hdr.extra_data[13].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_15_extra() {
        add_14_extra();
        hdr.extra_data[14].setValid();
        hdr.extra_data[14].padding = 0xFFFFFFFF;
    }
    @hidden
    action add_16_extra() {
        add_15_extra();
        hdr.extra_data[15].setValid();
        hdr.extra_data[15].padding = 0xFFFFFFFF;
    }

    @hidden
    table tb_int_extra_data {
        key = {
            local_metadata.int_meta.extra_data : exact;
        }
        actions = {
            add_0_extra;
            add_1_extra;
            add_2_extra;
            add_3_extra;
            add_4_extra;
            add_5_extra;
            add_6_extra;
            add_7_extra;
            add_8_extra;
            add_9_extra;
            add_10_extra;
            add_11_extra;
            add_12_extra;
            add_13_extra;
            add_14_extra;
            add_15_extra;
            add_16_extra;
        }
        const entries = {
            (0x0) : add_0_extra();
            (0x1) : add_1_extra();
            (0x2) : add_2_extra();
            (0x3) : add_3_extra();
            (0x4) : add_4_extra();
            (0x5) : add_5_extra();
            (0x6) : add_6_extra();
            (0x7) : add_7_extra();
            (0x8) : add_8_extra();
            (0x9) : add_9_extra();
            (0xA) : add_10_extra();
            (0xB) : add_11_extra();
            (0xC) : add_12_extra();
            (0xD) : add_13_extra();
            (0xE) : add_14_extra();
            (0xF) : add_15_extra();
            (0x1F) : add_16_extra();
        }
    }

    apply {
        tb_int_insert.apply();
        if (local_metadata.int_meta.transit == _FALSE) {
            return;
        }
        tb_int_inst_0003.apply();
        tb_int_inst_0407.apply();

        // Decrement remaining hop cnt
        hdr.int_header.remaining_hop_cnt = hdr.int_header.remaining_hop_cnt - 1;
        // Check if there is still to add INT header
        local_metadata.int_meta.extra_data = hdr.int_header.hop_metadata_len - (bit<5>) local_metadata.int_meta.new_words & 0b00011111;
        local_metadata.int_meta.new_words = local_metadata.int_meta.new_words + (bit<8>) local_metadata.int_meta.extra_data;
        local_metadata.int_meta.new_bytes = local_metadata.int_meta.new_bytes + ((bit<16>)local_metadata.int_meta.extra_data * 4);
        tb_int_extra_data.apply();
        // Update headers lengths.
        if (hdr.ipv4.isValid()) {
            hdr.ipv4.len = hdr.ipv4.len + local_metadata.int_meta.new_bytes;
        }
        if (hdr.udp.isValid()) {
            hdr.udp.length_ = hdr.udp.length_ + local_metadata.int_meta.new_bytes;
        }
        if (hdr.intl4_shim.isValid()) {
            hdr.intl4_shim.len = hdr.intl4_shim.len + local_metadata.int_meta.new_words;
        }
    }
}

#endif
