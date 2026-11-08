FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
ENV TZ=Asia/Shanghai
ENV PASSWORD=@Awf123456789
RUN apt-get update && apt-get install -y curl ca-certificates xz-utils jq; \
    S6_VER=$(curl -fsSL https://api.github.com/repos/just-containers/s6-overlay/releases/latest | jq -r .tag_name | sed 's/^v//'); \
    echo "s6-overlay latest: ${S6_VER}"; \
    s6arch="$(uname -m)"; \
    case "$s6arch" in \
      x86_64|amd64) s6arch="x86_64";; \
      aarch64|arm64) s6arch="aarch64";; \
      *) echo "Unsupported arch: $s6arch"; exit 1;; \
    esac; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz" -o /tmp/s6o-noarch.tar.xz; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6arch}.tar.xz" -o /tmp/s6o-${s6arch}.tar.xz; \
    tar -C / -Jxpf /tmp/s6o-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6o-${s6arch}.tar.xz; \
    rm -f /tmp/s6o*.tar.xz
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
curl \
sudo \
git \
wget \
build-essential \
python3 \
python3-pip \
nano \
zip \
unzip \
tar \
gzip \
bzip2 \
unminimize \
net-tools \
iproute2 \
ca-certificates \
tzdata \
procps \
lsb-release \
less \
iputils-ping \
traceroute \
dnsutils \
file \
tree \
htop \
vim \
locales \
software-properties-common \
ncdu \
util-linux \
fdisk \
telnet \
tcpdump \
rsync \
jq \
ripgrep \
watch \
bc \
passwd \
default-jdk \
man-db \
diffutils \
patch \
groff-base \
mtr \
language-pack-zh-hans \
openssh-server
RUN yes | unminimize && apt-get remove unminimize -y
RUN locale-gen zh_CN.UTF-8
RUN update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
RUN echo "root:${PASSWORD}" | chpasswd
RUN printf 'PermitRootLogin yes\nPasswordAuthentication yes\nPermitEmptyPasswords no\nPubkeyAuthentication yes\nUseDNS no\nX11Forwarding yes\nAllowTcpForwarding yes\nClientAliveInterval 10\nClientAliveCountMax 3\nMaxStartups 10:30:60\nLoginGraceTime 20\n' > /etc/ssh/sshd_config.d/99-custom.conf
RUN mkdir -p /etc/services.d/sshd; \
    printf '#!/bin/sh\nmkdir -p /run/sshd\nssh-keygen -A\nexec /usr/sbin/sshd -D -e -p 22\n' > /etc/services.d/sshd/run; \
    chmod +x /etc/services.d/sshd/run
USER root
ENTRYPOINT ["/init"]