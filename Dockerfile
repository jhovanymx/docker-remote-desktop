FROM ubuntu:16.04

EXPOSE 8000 6080
RUN apt-get update && \
    apt-get -y install sudo gnupg2 procps wget unzip mc curl && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    echo "secret\nsecret" | passwd user

# Install xvfb, blackbox, x11vnc, qupzilla & noVNC
USER user

RUN sudo apt-get update -qqy && \
    sudo apt-get -qqy install xvfb blackbox x11vnc qupzilla rxvt-unicode xfonts-terminus net-tools supervisor

RUN sudo mkdir -p /opt/noVNC/utils/websockify && \
    wget -qO- "https://github.com/kanaka/noVNC/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC && \
    wget -qO- "https://github.com/kanaka/websockify/tarball/master" | sudo tar -zx --strip-components=1 -C /opt/noVNC/utils/websockify
ADD index.html  /opt/noVNC

# Install MegaSync
RUN sudo apt-get -y install libc-ares2 libcrypto++9v5 libmediainfo0v5 libraw15 libzen0v5 apt-transport-https
RUN cd /home/user && \
    wget -q https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync_4.2.5+1.1_amd64.deb && \
    sudo dpkg -i megasync_4.2.5+1.1_amd64.deb && \
    rm -f megasync_4.2.5+1.1_amd64.deb

# Configure Blackbox
RUN sudo mkdir -p /etc/X11/blackbox
ADD blackbox-menu /etc/X11/blackbox

ENV DISPLAY :20.0
ENV TERM xterm

ADD supervisord.conf /etc/supervisor/conf.d

CMD sudo supervisord & bash