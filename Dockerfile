FROM debian:buster-slim

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -yq && \
    apt install -yq --no-install-recommends \
        build-essential \
        ca-certificates wget \
        sudo

# Creating regular user 'developer':
ARG USER=developer
RUN addgroup "$USER" && \
    adduser --disabled-password --gecos "" --ingroup "$USER" --home "/home/$USER" "$USER" && \
    addgroup "$USER" sudo && \
    echo -e '%sudo ALL=(ALL) NOPASSWD:ALL\nDefaults env_keep += "HOME"' >> /etc/sudoers

USER "$USER"
ENV src_dir="/home/$USER/src"
RUN mkdir -p -- "$src_dir/docker"
WORKDIR "$src_dir/docker"

ENV PATH="/home/$USER/.local/bin:$PATH"

COPY ["docker/Makefile", "./"]
RUN sudo make ruby-install && \
    sudo make ruby-install/clean && \
    make ruby && \
    sudo make chruby && \
    sudo make chruby/profile.d && \
    sudo make chruby/clean && \
    make bundler

COPY ["Gemfile", "Gemfile.lock", "../"]
RUN make dependencies

COPY [".", "../"]
RUN sudo chown -R "$USER:$USER" ../
CMD make jekyll/serve
