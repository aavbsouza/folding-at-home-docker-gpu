FROM nvidia/cuda:10.2-base-ubuntu18.04

ARG version="v7.5"

RUN apt-get update && apt-get install -y --no-install-recommends \
# Install PPA dependency
    software-properties-common \
# Install Time Zone Database
        tzdata && \
# Install folding@home client
    useradd --system folding && \
    mkdir -p /opt/fahclient && \
# download and untar
    apt-get update -y && \
    apt-get install -y wget bzip2 && \
    wget https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/${version}/latest.tar.bz2 -O /tmp/fahclient.tar.bz2 && \
    tar -xjf /tmp/fahclient.tar.bz2 -C /opt/fahclient --strip-components=1 && \
# fix permissions
    chown -R folding:folding /opt/fahclient && \
# cleanup
    rm -rf /tmp/fahclient.tar.bz2 && \
# Install Nvidia OpenCL
    add-apt-repository -y ppa:graphics-drivers && \
    apt-get update && apt-get install -y --install-recommends \
    nvidia-opencl-dev && \
# Cleaning up
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=folding:folding entrypoint.sh /opt/fahclient

RUN chmod +x /opt/fahclient/entrypoint.sh

ENV USER "Anonymous"
ENV TEAM "0"
ENV ENABLE_GPU "true"
ENV ENABLE_SMP "true"
ENV POWER "full"

USER folding
WORKDIR /opt/fahclient

EXPOSE 7396
EXPOSE 36330

ENTRYPOINT ["/opt/fahclient/entrypoint.sh"]


