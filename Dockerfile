FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    gdb \
    python3 \
    python3-pip \
    python3-dev \
    git \
    wget \
    curl \
    netcat-openbsd \
    cmake \
    file


# Install checksec
RUN git clone https://github.com/slimm609/checksec.sh.git /opt/checksec \
    && ln -s /opt/checksec/checksec /usr/local/bin/checksec

# Install pwntools and other Python packages
RUN pip3 install --no-cache-dir \
    pwntools \
    ropper \
    capstone \
    keystone-engine \
    unicorn

# Install pwndbg for GDB
RUN git clone https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg \
    && ./setup.sh

# Create working directory
WORKDIR /ctf

# Copy challenge files
COPY challenge/ /ctf/challenge/
COPY solution/ /ctf/solution/

# Build the vulnerable binary
RUN cd /ctf/challenge && make

# Create a sample flag for testing
RUN echo "SGTECHCTF{buff3r_0v3rfl0w_m4st3r}" > /ctf/challenge/flag.txt

# Set permissions
RUN chmod +x /ctf/challenge/vuln \
    && chmod +x /ctf/solution/exploit.py

# Expose port for remote challenges (if running as a service)
EXPOSE 1337

# Default command - interactive shell
CMD ["/bin/bash"]