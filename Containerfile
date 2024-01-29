FROM ghcr.io/ublue-os/arch-distrobox:latest

LABEL com.github.containers.toolbox="true" \
    usage="This image is meant to be used with the toolbox or distrobox command" \
    summary="My personal distrobox development environment"

COPY extra-packages /
RUN paru -Syu --noconfirm && \
    paru -S --needed - < /extra-packages
RUN rm /extra-packages

# change distrobox cache dir to keep distrobox and host fontconfig caches separate
# prevents fonts from breaking between host and container due to changing paths
RUN echo 'export XDG_CACHE_HOME="$HOME/.cache-distrobox"' > /etc/profile.d/cache-home.sh

# install Bun, and keep npm up to date (npm should be present as part of extra-packages above)
RUN npm install -g typescript typescript-language-server

RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/ujust
