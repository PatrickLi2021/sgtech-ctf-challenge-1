# Buffer Overflow CTF Challenge (S&G Tech CTF 2026)

## Overview
This is a classic buffer overflow challenge where a vulnerable "Greeter App" binary uses the unsafe `gets()` function. The goal is to overflow the stack buffer in `greet()` to redirect execution to the hidden `win()` function, which reads and prints the flag.

## Architecture

```
sgtech-ctf-challenge-1/
├── Dockerfile          # x86-64 Ubuntu 22.04 container with pwn tools
├── docker-compose.yml  # Two services: interactive CTF env + challenge server
├── challenge/
│   ├── vuln.c          # Vulnerable C source code
│   ├── vuln            # Compiled binary (x86-64 ELF)
│   └── Makefile        # Builds the vulnerable binary with protections disabled
└── solution/
    └── exploit.py      # pwntools exploit script
    └── README.md       # Exploit writeup
```

## Docker Services
| Service | Container Name | Purpose |
|---------|------|-------------|
| `ctf` | `sgtechctf-pwn` | Interactive shell for solving the challenge |
| `server` | `sgtechctf-server` | Exposes the binary over TCP on port 1337 via socat |

## Getting Started

### Prerequisites
Ensure that you have both Docker Desktop installed and Docker Compose (v2 plugin or standalone `docker-compose`) installed (not sure if Colima will work, but it might).

### Steps
1. **Build the Container:** Run `docker compose build --no-cache` to build the container
2.

## Apple Silicon Considerations
This container is built for **x84-64** (`--plaform=linux/amd64`). On Apple Silicon Macs, this has important implications:

### Issues with x86-64 binaries and the Use of QEMU
When you compile a C program, the compiler generates machine instructions for a specific CPU architecture. As an example, x86-64 instructions are specifically designed for Intel and AMD CPUs. An ARM CPU (such as the one your Apple M1-M4 Mac uses) literally does not understand these instructions. 

Even when we run the program inside a Docker container, it won't work because Docker containers share the host kernel and CPU architecture. So, native containers still run as ARM64. x86-64 containers require an emulator/translation layer underneath.

To run an x86-64 binary on an ARM-based Mac, Docker must rely on an emulator or translation layer such as QEMU or Rosetta 2. These tools dynamically translate x86-64 instructions into ARM64 instructions while the program runs. For this challenge, we use QEMU.

### Using GDB and Issues with GDB
GNU Debugger (GDB) is a low-level program debugger used primarily for C, C++, and systems programming languages on Linux systems. It basically lets you observe and control another program while it executes. You can do things like set break points, inspect values in registers/variables, and analyze addresses of functions. 

Now, __even__ with using QEMU, we stil run into issues unfortunately, since GDB is vitally important to this challenge. When Docker uses QEMU, the entire Linux guest runs inside a QEMU process. This means that GDB cannot directly attach to the process because it's running inside another QEMU process (on Linux, only one processs can ptrace another at a time). You can think of it as 2 people trying to hold the steering wheel at the same time - it just doesn't work.

### The Final Solution and How this Challenge Will Work
QEMU user-mode (`qemu-x86_64`) doesn't use ptrace to control the target. Instead, it runs **everything** inside a single process and provides its own debugging interface. So inside that single process, we have the software-emulated x86-64 CPU __and__ the GDB remote protocol server. The GDB client is listening on a particular TCP port that your process will essentially connect to. As a result, when GDB asks what the value of a particular register is, QEMU reads it from its own internal data structure - not from hardware or the operating system kernel.