FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
ENV TZ=Asia/Shanghai
ENV S6_OVERLAY_VERSION=3.2.0.0
RUN apt-get update && apt-get install -y curl xz-utils; \
    s6arch="$(uname -m)"; \
    case "$s6arch" in \
      x86_64|amd64) s6arch="x86_64";; \
      aarch64|arm64) s6arch="aarch64";; \
      *) echo "Unsupported arch: $s6arch"; exit 1;; \
    esac; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" -o /tmp/s6o-noarch.tar.xz; \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${s6arch}.tar.xz" -o /tmp/s6o-${s6arch}.tar.xz; \
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
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN locale-gen zh_CN.UTF-8
RUN update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
RUN mkdir -p /etc/services.d/code-server; \
    printf '#!/bin/sh\nexec code-server --bind-addr 0.0.0.0:8080 --auth none\n' > /etc/services.d/code-server/run; \
    chmod +x /etc/services.d/code-server/run
USER root
ENTRYPOINT ["/init"]