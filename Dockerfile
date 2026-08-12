FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV PATH="/root/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"

RUN userdel -r ubuntu 2>/dev/null || true

# Base tools + Python 3.11 repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        gnupg \
        curl \
        wget \
        apt-transport-https \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        python3.11-distutils \
        python3-pip \
        \
        git \
        build-essential \
        gcc \
        g++ \
        make \
        pkg-config \
        \
        libffi-dev \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        liblzma-dev \
        zlib1g-dev \
        \
        ripgrep \
        ffmpeg \
        \
        jq \
        tree \
        file \
        which \
        less \
        nano \
        vim \
        htop \
        tmux \
        screen \
        rsync \
        unzip \
        zip \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        zstd \
        \
        iproute2 \
        iputils-ping \
        dnsutils \
        net-tools \
        traceroute \
        telnet \
        netcat-openbsd \
        openssl \
        \
        openssh-client \
        openssh-server \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Python 3.11 defaults
RUN ln -sf /usr/bin/python3.11 /usr/local/bin/python3 && \
    ln -sf /usr/bin/python3.11 /usr/local/bin/python && \
    python --version && \
    python3 --version && \
    python3.11 --version

# SSH
RUN mkdir -p /run/sshd && \
    chmod 755 /run/sshd && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    grep -q '^PasswordAuthentication' /etc/ssh/sshd_config || \
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    grep -q '^PermitRootLogin' /etc/ssh/sshd_config || \
        echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Verify all critical dependencies at BUILD time
RUN set -eux; \
    python --version; \
    python3 --version; \
    python3.11 --version; \
    python3.11 -m venv /tmp/test-venv; \
    /tmp/test-venv/bin/python --version; \
    rm -rf /tmp/test-venv; \
    git --version; \
    curl --version | head -1; \
    wget --version | head -1; \
    rg --version | head -1; \
    ffmpeg -version | head -1; \
    ssh -V 2>&1; \
    gcc --version | head -1; \
    jq --version

COPY ssh-user-config.sh /usr/local/bin/ssh-user-config.sh

RUN chmod +x /usr/local/bin/ssh-user-config.sh

EXPOSE 22

CMD ["/usr/local/bin/ssh-user-config.sh"]
