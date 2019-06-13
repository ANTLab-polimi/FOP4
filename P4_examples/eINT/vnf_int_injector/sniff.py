from scapy.all import *
import psutil
import argparse
import datetime
from int_header import INT_v10

epoch = datetime.datetime.utcfromtimestamp(0)


def increase_len_ip_udp(packet, len):
    packet[IP].len += len
    packet[UDP].len += len
    del packet[IP].chksum
    del packet[UDP].chksum
    return packet


def add_int_vnf_data(packet, vnf_id):
    # TODO: CHECK IF IT IS CORRECT. It may have problem if the UDP payload is more than just INT data
    int_content = INT_v10(packet[UDP].payload)
    len_int_meta_to_add = 0
    if int_content.remainHopCnt > 0:
        int_content.remainHopCnt -= 1

        # Check dimension of the INT metadata Hop by Hop
        # print("LEN INS", bin(int_content.ins).count('1'))
        # print("LEN VNF_INS", bin(int_content.vnf_ins).count('1'))
        assert int_content.hopMLen == max([bin(int_content.ins).count('1'), bin(int_content.vnf_ins).count('1')])
        len_int_meta_to_add = int_content.hopMLen # It should be the same as max([bin(int_content.ins).count('1'), bin(int_content.vnf_ins).count('1')])
        int_meta_to_add = get_int_data_from_VNF(int_content.vnf_ins, vnf_id)
        # print("INT_META", int_meta_to_add)

        # Check dimension of the complete INT metadata
        assert int_content.length - 3 == len(int_content.INTMetadata)
        old_len = int_content.length - 3 # It should be the same as len(int_content.INTMetadata)

        int_content.INTMetadata[:0] = [XIntField("", None) for i in range(len_int_meta_to_add)]

        # Add actual INT data collected in this VNF
        # for i, j in zip(range(old_len, len(int_meta_to_add)+old_len), range(len(int_meta_to_add))):
        for i in range(len(int_meta_to_add)):
            int_content.INTMetadata[i] = int_meta_to_add[i]
        # Put to 0xFFFFFFFF the padding to reach the HOP_ML field
        for i in range(len(int_meta_to_add), len_int_meta_to_add):
            int_content.INTMetadata[i] = 0xFFFFFFFF

        # print(int_content.INTMetadata)

        # Increase the length of the int content by HopMLen
        int_content.length += int_content.hopMLen
    else:
        # Set the e bit if the remaining hop count is 0
        int_content.e = 0b1
    packet[UDP].payload = int_content
    return packet, len_int_meta_to_add


def unix_time_millis(dt):
    return (dt - epoch).total_seconds() * 1000.0


def get_int_data_from_VNF(vnf_mask, vnf_id):
    # Recover the data from the current VNF
    # print("VNF MASK " + bin(vnf_mask))
    int_data = []
    if vnf_mask & 0b10000000:
        # VNF ID
        int_data.append(int(vnf_id))
    if vnf_mask & 0b01000000:
        # CPU usage
        int_data.append(int(psutil.cpu_percent()))
    if vnf_mask & 0b00100000:
        # Memory usage
        int_data.append(int(psutil.virtual_memory()._asdict()['percent']))
    if vnf_mask & 0b00010000:
        # Timestamp
        int_data.append(int(unix_time_millis(datetime.datetime.utcnow())))
    return int_data


# create parent function with passed in arguments
def add_vnf_metrics(out_intf, vnf_id):
    s = conf.L2socket(iface=out_intf)
    def sniff_packet(packet):
        ip_layer = packet.getlayer(IP)
        udp_layer = ip_layer.getlayer(UDP)
        # print("[!] New Packet: {src} -> {dst}".format(src=ip_layer.src, dst=ip_layer.dst))
        # print("      UDP PORT: {src} -> {dst}".format(src=udp_layer.sport, dst=udp_layer.dport))
        # print(packet.show())

        int_layer = INT_v10(udp_layer.payload)
        # print(int_layer.INTMetadata, int_layer.length)
        packet, len_added = add_int_vnf_data(packet, vnf_id)
        packet = increase_len_ip_udp(packet, len_added*4)
        # print(int_layer.INTMetadata, int_layer.length)
        # print(packet.show2())

        # sendp(packet, iface=out_intf)
        s.send(packet)

    return sniff_packet


def main():
    parser = argparse.ArgumentParser()

    # ------------------------------ MODEL PARAMETERS -----------------------------------------------------------------
    parser.add_argument('--in_intf', help='Input Interface', type=str, required=True)
    parser.add_argument('--out_intf', help='Output Interface', type=str, required=True)
    parser.add_argument('--vnf_id', help='ID of the current VNF', type=int, required=True)

    # ###################################### Parse input arguments ######################################
    # ----------------------------------- Input arguments -------------------------------------
    args = parser.parse_args()

    #                                   ## Model parameters ##
    in_intf = args.in_intf
    out_intf = args.out_intf
    vnf_id = args.vnf_id

    print("[*] Start sniffing...")
    sniff(iface=in_intf, filter="ip", prn=add_vnf_metrics(out_intf, vnf_id))
    print("[*] Stop sniffing")


if __name__ == "__main__":
    main()
