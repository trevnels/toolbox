FROM ghcr.io/ublue-os/fedora-distrobox:latest

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="My personal distrobox development environment"

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

COPY extra-packages /
RUN dnf -y update --skip-broken && \
    grep -v '^#' /extra-packages | xargs dnf -y install
RUN rm /extra-packages

# install Bun, and keep npm up to date (npm should be present as part of extra-packages above)
RUN npm install -g bun npm typescript typescript-language-server

# install Typst
RUN wget -qO- https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar -xJ -C /tmp/ && \
    mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/ && \
    rm -rf /tmp/typst-x86_64-unknown-linux-musl

RUN   ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
