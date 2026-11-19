FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
ENV TZ=Asia/Shanghai
RUN apt-get update && apt-get install -y curl xz-utils; \
    s6arch="$(uname -m)"; \
    case "$s6arch" in \
      x86_64|amd64) s6arch="x86_64";; \
      aarch64|arm64) s6arch="aarch64";; \
      *) echo "Unsupported arch: $s6arch"; exit 1;; \
    esac; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-noarch.tar.xz" -o /tmp/s6o-noarch.tar.xz; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-${s6arch}.tar.xz" -o /tmp/s6o-${s6arch}.tar.xz; \
    tar -C / -Jxpf /tmp/s6o-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6o-${s6arch}.tar.xz; \
    rm -f /tmp/s6o*.tar.xz
RUN apt update && apt upgrade -y && apt install -y \
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
language-pack-zh-hans
RUN yes | unminimize && apt remove unminimize -y
RUN locale-gen zh_CN.UTF-8
RUN update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
RUN curl -L https://raw.githubusercontent.com/nezhahq/scripts/main/agent/install.sh -o /root/agent.sh && \
    chmod +x /root/agent.sh && \
    env NZ_SERVER=crossover.proxy.rlwy.net:47728 NZ_TLS=false NZ_CLIENT_SECRET=inm4YnLGIAaIcQ7Ef1Nl2CUr5sCLZoUz /root/agent.sh || true; \
    rm -f /root/agent.sh
RUN mkdir -p /opt/nezha/agent && \
    printf 'server: crossover.proxy.rlwy.net:47728\nclient_secret: inm4YnLGIAaIcQ7Ef1Nl2CUr5sCLZoUz\ntls: false\n' > /opt/nezha/agent/config.yml
RUN mkdir -p /etc/services.d/nezha-agent; \
    printf '#!/bin/sh\nexec /opt/nezha/agent/nezha-agent -c /opt/nezha/agent/config.yml\n' > /etc/services.d/nezha-agent/run; \
    chmod +x /etc/services.d/nezha-agent/run
USER root
ENTRYPOINT ["/init"]