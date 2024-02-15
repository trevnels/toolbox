FROM ghcr.io/ublue-os/arch-distrobox:latest

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox command" \
    summary="My personal distrobox development environment"

# install packages
COPY extra-packages /
COPY aur-packages /

RUN mkdir -p /etc/fish/conf.d
COPY distrobox.fish /etc/fish/conf.d/

RUN sed -i 's|NoExtract  = usr/share/man/\* usr/share/info/\*||' /etc/pacman.conf && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# restore manpages
RUN mkdir -p /usr/share/man && \
    pacman -Qqo /usr/share/man | pacman -Syu --noconfirm -

# install normal packages
RUN pacman -S --noconfirm --needed $(cat /extra-packages)

USER build
WORKDIR /home/build
# update and install aur packages
RUN paru -Syu --noconfirm --needed $(cat /aur-packages)

USER root
WORKDIR /

RUN rm /extra-packages /aur-packages

# change distrobox cache dir to keep distrobox and host fontconfig caches separate
# prevents fonts from breaking between host and container due to changing paths
# RUN echo 'export XDG_CACHE_HOME="$HOME/.cache-distrobox"' > /etc/profile.d/cache-home.sh

# install ts & its lsp
RUN npm install -g typescript typescript-language-server

RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/ujust


# Cleanup
RUN userdel -r build && \
    rm -drf /home/build && \
    sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
