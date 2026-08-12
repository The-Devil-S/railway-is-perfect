FROM ubuntu:24.04

# ============================================================
# Base
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Ubuntu 24.04 ships with a default "ubuntu" user (UID/GID 1000).
# Remove it so UID/GID 1000 remains available for the SSH user.
RUN userdel -r ubuntu 2>/dev/null || true


# ============================================================
# System packages
# ============================================================

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        gnupg \
        gpg \
        apt-transport-https \
        software-properties-common \
        lsb-release \
        tzdata \
        locales \
        file \
        which \
        tree \
        less \
        nano \
        vim \
        htop \
        tmux \
        screen \
        jq \
        unzip \
        zip \
        rsync \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        zstd \
        build-essential \
        gcc \
        g++ \
        make \
        pkg-config \
        python3 \
        python3.11 \
        python3.11-dev \
        python3.11-venv \
        python3-pip \
        libffi-dev \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        liblzma-dev \
        zlib1g-dev \
        ripgrep \
        ffmpeg \
        iproute2 \
        iputils-ping \
        dnsutils \
        net-tools \
        traceroute \
        telnet \
        netcat-openbsd \
        openssl \
        openssh-client \
        openssh-server \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ============================================================
# Python 3.11
# ============================================================

# Make Python 3.11 the default "python3".
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 20 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 20 && \
    python3 --version && \
    python --version


# ============================================================
# SSH
# ============================================================

RUN mkdir -p /run/sshd && \
    chmod 755 /run/sshd && \
    \
    # SSH configuration
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    \
    # Make sure these settings exist even if the Ubuntu config changes.
    grep -q '^PasswordAuthentication' /etc/ssh/sshd_config || \
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    grep -q '^PermitRootLogin' /etc/ssh/sshd_config || \
        echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config


# ============================================================
# Environment / PATH
# ============================================================

ENV PATH="/root/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"

# Ensure root's local bin exists.
RUN mkdir -p /root/.local/bin


# ============================================================
# Verify everything that Hermes / the container needs
# ============================================================

RUN set -eux; \
    echo "=== Versions ==="; \
    python --version; \
    python3 --version; \
    pip3 --version; \
    git --version; \
    curl --version | head -1; \
    wget --version | head -1; \
    rg --version | head -1; \
    ffmpeg -version | head -1; \
    ssh -V 2>&1; \
    gcc --version | head -1; \
    g++ --version | head -1; \
    make --version | head -1; \
    jq --version


# ============================================================
# SSH user configuration
# ============================================================

COPY ssh-user-config.sh /usr/local/bin/ssh-user-config.sh

RUN chmod +x /usr/local/bin/ssh-user-config.sh


# ============================================================
# Railway
# ============================================================

EXPOSE 22


# ============================================================
# Container startup
# ============================================================

CMD ["/usr/local/bin/ssh-user-config.sh"]
