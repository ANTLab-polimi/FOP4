all: program

program: program.p4
	p4c-xdp --target xdp -o program.c program.p4
	clang -I ${P4C}/extensions/p4c-xdp/p4include -I${P4C}/backends/ebpf/runtime/ \
		-Wno-unused-value -Wno-pointer-sign \
		-Wno-compare-distinct-pointer-types \
		-Wno-gnu-variable-sized-type-not-at-end \
		-Wno-tautological-compare \
		-O2 -emit-llvm -g -c program.c  -o -| llc -march=bpf -filetype=obj -o program.o
