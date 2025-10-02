FROM dorowu/ubuntu-desktop-lxde-vnc

COPY src/install_chrome.sh .
RUN ./install_chrome.sh

COPY auth/docker-entrypoint.sh /
COPY auth/desktop /etc/skel/Desktop

ENV USER=abc
ENTRYPOINT [ "/docker-entrypoint.sh" ]