FROM debian

ARG DEBIAN_FRONTEND=noninteractive
ARG SERVER_URL=https://cdn.rage.mp/lin/ragemp-srv.tar.gz
ARG BRIDGE_URL=http://cdn.gtanet.work/bridge-package-linux.tar.gz

# Install dependencies
RUN apt-get update
RUN apt-get install -y \
    libunwind8 \
    icu-devtools \
    curl \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# RUN apt-get install -y \
#     gettext \
#     apt-transport-https \
#     gnupg2
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
#     mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
#     sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/dotnetdev.list' && \
#     apt-get update && \
#     apt-get install -y dotnet-sdk-2.0.0 && \
#     rm -rf /var/lib/apt/lists/*

# Add rage user
RUN adduser --disabled-password --gecos "" rage
RUN mkdir -p /home/rage/server

# Download required packages
RUN mkdir /tmp/server/
RUN cd /tmp/server && \
    curl $SERVER_URL -o ragemp-srv.tar.gz && \
    tar -xzf ragemp-srv.tar.gz && \
    mv -v ragemp-srv/* /home/rage/server && \
    rm -rf /tmp/server

RUN mkdir /tmp/bridge/
RUN cd /tmp/bridge && \
    curl $BRIDGE_URL -o bridge-package-linux.tar.gz && \
    tar -xzf bridge-package-linux.tar.gz && \
    mv -v plugins/* /home/rage/server/plugins && \
    rm -rf /tmp/bridge

# Expose Ports and start the Server
WORKDIR /home/rage/server
RUN chown -R rage:rage .
EXPOSE 22005/udp 22006

ADD ./entrypoint.sh ./entrypoint.sh
RUN chmod +x server
RUN chmod +x entrypoint.sh

USER rage
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
