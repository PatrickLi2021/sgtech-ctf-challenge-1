# Solver Environment for Buffer Overflow Challenge
# Build:    docker build -t ctf-solver .
# Run:      docker run -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined ctf-solver

FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    gdb \
    gdb-multiarch \
    qemu-user \
    python3 \
    python3-pip \
    python3-dev \
    git \
    wget \
    curl \
    netcat-openbsd \
    file \
    && rm -rf /var/lib/apt/lists/*

# Install checksec
RUN git clone https://github.com/slimm609/checksec.sh /opt/checksec \
    && ln -s /opt/checksec/checksec /usr/local/bin/checksec

# Install pwntools
RUN pip3 install --no-cache-dir pwntools ropper capstone

WORKDIR /ctf
COPY challenge/vuln /ctf/vuln
COPY challenge/vuln.c /ctf/vuln.c

CMD ["/bin/bash"]