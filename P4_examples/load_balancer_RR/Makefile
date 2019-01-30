all: loadbalancer

loadbalancer: load_balancer_RR.p4
	p4c-bm2-ss --arch v1model -o load_balancer_RR.json \
		--p4runtime-file mytunload_balancer_RRnel.p4info --p4runtime-format text \
		load_balancer_RR.p4
