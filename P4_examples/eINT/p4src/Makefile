all: int

int: int.p4
	p4c-bm2-ss --arch v1model -o p4c-out/bmv2/int.json "-DTARGET_BMV2" \
		--p4runtime-files p4c-out/bmv2/int_p4info.txt \
		int.p4

clean:
	rm -rf p4c-out/bmv2/*
