from scapy.all import *


class INT_v10(Packet):
    name = "INT v1.0"

    fields_desc = [
        # ----- Shim header ------ (4 Bytes)
        XByteField("type", 1),
        XByteField("shimRsvd1", None),
        XByteField("length", None), # --> lunghezza totale della parte di int (INT header+metadata+shim) in numero di 4-byte words
        BitField("dscp", None, 6),
        BitField("shimRsvd2", None, 2),
        # ------------------------

        # ----- Header INT ------- (4 Bytes)
        BitField("ver", 0, 4),
        BitField("rep", 0, 2),
        BitField("c", 0, 1),
        BitField("e", 0, 1),
        BitField("m", 0, 1),
        BitField("rsvd1", 0, 7),
        BitField("rsvd2", 0, 3),
        BitField("hopMLen", None, 5),
        XByteField("remainHopCnt", None),

        XByteField("ins", None),
        XByteField("vnf_ins", None),
        XShortField("reserved", None),
        # -------------------------

        # ----- INT METADATA ------
        # (Multiple of 4 bytes, length is length in the shim header - 3 (the 2*4bytes of shim and INT header)
        FieldListField("INTMetadata", [], XIntField("", None), count_from=lambda p: p.length - 3)
        # ------------------------
    ]
