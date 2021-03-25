# P4-XDP on P4-Containernet

## Installation
### Manual installation
Follow instruction from [here](https://github.com/vmware/p4c-xdp) to install the P4_16-XDP compiler.
Then set the environment variable `$P4C` to the path of the P4 compiler folder (usually `~/p4c/`).

### Automatic installation
Alternatively, you can install the compiler by executing the script `FOP4/util/install-p4c-xdp.sh`.
The script will add necessary environment variables to your bash profile file.
To load them without rebooting, run `source ~/.profile`

## Compile P4 program for eBPF-XDP target (p4c-xdp)
You can compile the P4 program to the eBPF-XDP target running the following commands. First copy the `ebpf_xdp.h`
```bash
cp ${P4C}/extensions/p4c-xdp/tests/ebpf_xdp.h .
p4c-xdp --target xdp -o PROGRAM_NAME.c PROGRAM_NAME.p4
clang -I ${P4C}/extensions/p4c-xdp/p4include -I${P4C}/backends/ebpf/runtime/ -I${P4C}/backends/ebpf/runtime/usr/include/bpf \
    -Wno-unused-value -Wno-pointer-sign \
    -Wno-compare-distinct-pointer-types \
    -Wno-gnu-variable-sized-type-not-at-end \
    -Wno-tautological-compare \
    -O2 -emit-llvm -g -c PROGRAM_NAME.c  -o -| llc -march=bpf -filetype=obj -o PROGRAM_NAME.o
```
## How to use a compiled eBPF-XDP program in P4-Containernet

To use the previously compiled program you should add an eBFP enabled host to your topology (`EbpfXdpNode`). Then, when you create a link from that host, you can specify which compiled eBFP-XDP program has to be loaded to the interface.


Here is an example:
```python
net = Containernet()
h = net.addEbpfHost('h1')
s = net.addSwitch('s1')
net.addLink(h, s, ebpfProgram1="./PROGRAM_NAME.o")
# or net.addLink(s, h, ebpfProgram2="./PROGRAM_NAME.o")

```
The interface accept any eBPF-XDP program, not only the ones obtained with the **p4c-xdp** compiler.