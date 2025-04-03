# Pulls base image that contains VNC.
FROM jlesage/baseimage-gui:debian-11

LABEL author="Atom" maintainer="admin@atomservices.cc"

# Environment Variables.
ENV GAME_PATH="/home/container/StardewValley"
ENV HOME="/home/container"

# Update and install dependencies.
RUN apt-get update \
    && apt upgrade -y \
    && apt install -y \
    curl \
    tar \
    unzip \
    locales \
    strace \
    mono-complete \
    xterm \
    gettext-base \
    jq \
    netcat \
    procps \
    lib32gcc-s1 \
    libssl1.1

# Create directories
RUN mkdir -p ${GAME_PATH} \
    && mkdir -p /opt

# Install .NET.
RUN cd /tmp/ \
    && curl -sSL -o dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/d4b71fac-a2fd-4516-ac58-100fb09d796a/e79d6c2a8040b59bf49c0d167ae70a7b/dotnet-sdk-5.0.408-linux-arm64.tar.gz \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet/ \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Configure locales.
RUN update-locale lang=en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN useradd -m -d /home/container -s /bin/bash container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Set directory permissions
RUN chown -R container:container ${HOME} \
    && chown -R container:container ${GAME_PATH} \
    && chown -R container:container /var \
    && chown -R container:container /opt

# Set User.
USER container

## Create start.sh
RUN touch ${GAME_PATH}/start.sh \
    && echo "#!/bin/bash" > ${GAME_PATH}/start.sh \
    && echo "echo Running Stardew Valley" >>  ${GAME_PATH}/start.sh \
    && echo "cd /home/container/StardewValley" >>  ${GAME_PATH}/start.sh \
    && echo "chmod +x *" >> ${GAME_PATH}/start.sh\
    && echo "./'StardewModdingAPI'" >> ${GAME_PATH}/start.sh

# Create SMAPI log file
RUN touch /opt/tail-smapi-log.sh \
    && echo "#!/bin/sh" > /opt/tail-smapi-log.sh \
    && echo "echo '-- SMAPI Log: Starting'" >> /opt/tail-smapi-log.sh \
    && echo "# Wait for SMAPI log and tail infinitely" >> /opt/tail-smapi-log.sh \
    && echo "while [ ! -f '/config/xdg/config/StardewValley/ErrorLogs/SMAPI-latest.txt' ]; do" >> /opt/tail-smapi-log.sh \
    && echo "  echo '-- SMAPI Log: Waiting for log to appear';" >> /opt/tail-smapi-log.sh \
    && echo "  sleep 5;" >> /opt/tail-smapi-log.sh \
    && echo "done" >> /opt/tail-smapi-log.sh \
    && echo "echo '-- SMAPI Log:  Tailing'" >> /opt/tail-smapi-log.sh \
    && echo "tail -f /config/xdg/config/StardewValley/ErrorLogs/SMAPI-latest.txt" >> /opt/tail-smapi-log.sh

# Set file permissions
RUN chmod -R 777 $GAME_PATH \
    && chmod +x /opt/*.sh \
    && chmod +x $GAME_PATH/start.sh

STOPSIGNAL  SIGINT

COPY --chown=container:container ./entrypoint.sh /startapp.sh
RUN chmod +x /startapp.sh