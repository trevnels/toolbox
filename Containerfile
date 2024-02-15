FROM ghcr.io/ublue-os/arch-distrobox:latest

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox command" \
    summary="My personal distrobox development environment"

# install packages
COPY extra-packages /

RUN mkdir -p /etc/fish/conf.d
COPY distrobox.fish /etc/fish/conf.d/

RUN sed -i 's|NoExtract  = usr/share/man/\* usr/share/info/\*||' /etc/pacman.conf && \
    useradd -m --shell=/bin/bash build && usermod -L build && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /usr/share/man
# figure out what needs to be reinstalled to populate manpages.
# exclude xdg-utils-distrobox since it comes from a gh repo and not the aur
RUN sh -c "pacman -Qqo /usr/share/man | sed 's|xdg-utils-distrobox||' > /to-reinstall"

USER build
WORKDIR /home/build

# reinstall/upgrade everything with manpages based on the config change we make above
# also install extra-packages
RUN paru -Syu --noconfirm $(cat /to-reinstall /extra-packages) 

# reinstall xdg-utils-distrobox to get its manpages
RUN git clone https://github.com/KyleGospo/xdg-utils-distrobox-arch.git --single-branch && \
    cd xdg-utils-distrobox-arch/trunk && \
    makepkg -si --noconfirm && \
    cd ../.. && \
    rm -drf xdg-utils-distrobox-arch

USER root
WORKDIR /

RUN rm /to-reinstall /extra-packages

# change distrobox cache dir to keep distrobox and host fontconfig caches separate
# prevents fonts from breaking between host and container due to changing paths
# RUN echo 'export XDG_CACHE_HOME="$HOME/.cache-distrobox"' > /etc/profile.d/cache-home.sh
# ^ this now happens as part of fish config

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
