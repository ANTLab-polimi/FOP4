all: loadbalancer

loadbalancer: load_balancer_hash.p4
	p4c-bm2-ss --arch v1model -o load_balancer_hash.json \
		--p4runtime-file load_balancer_hash.p4info --p4runtime-format text \
		load_balancer_hash.p4
