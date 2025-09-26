FROM dorowu/ubuntu-desktop-lxde-vnc

# Setup environment variables
ENV HOME=/home/abc \
    USER=abc \
    PUID=1000 \
    PGID=1000 \
    CHROME_PACKAGE=google-chrome-stable_current_amd64.deb

RUN \
    # Create a non-root user
    addgroup abc --gid "${PGID}" --quiet \
    && adduser abc --uid "${PUID}" --gid "${PGID}" --disabled-password --gecos "" --quiet \
    && echo 'abc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install/update Chrome
RUN \
    wget https://dl.google.com/linux/direct/$CHROME_PACKAGE && \
    dpkg --force-all -i ./$CHROME_PACKAGE && \
    rm ./$CHROME_PACKAGE && \
    rm -rf /var/lib/apt/lists/*

COPY startup2.sh /startup2.sh

ENTRYPOINT [ "/startup2.sh" ]