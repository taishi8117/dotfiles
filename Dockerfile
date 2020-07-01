FROM ubuntu:18.04
MAINTAINER Taishi Nojima

# Install dependencies
# Here, sync with ./dep/ubuntu.sh.
RUN apt-get update && apt-get install -y software-properties-common && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:neovim-ppa/stable

RUN apt-get update && apt-get install -y \
        sudo \
        git \
        zsh \
        tmux \
        neovim \
        python \
        python3 \
        python3-pip \
        wget \
        gawk \
        net-tools \
        curl \
        locales \
        httpie \
        python-pygments \
        shellcheck \
        jq \
        && rm -rf /var/lib/apt/lists/*

RUN ln -sfn python3 /usr/bin/python
RUN ln -sfn pip3 /usr/bin/pip

# Create user
RUN useradd -m -s /bin/zsh sirius
RUN usermod -aG sudo sirius
RUN usermod -aG root sirius
RUN echo "sirius ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers

# Add dotfiles and chown
ADD . /home/sirius/dotfiles
RUN chown -R sirius:sirius /home/sirius

# Switch user
USER sirius
ENV HOME /home/sirius
ENV TERM xterm-256color
ENV ZPLUG_HOME /home/sirius/.zplug
ENV LANG en_US.UTF-8
ENV DOTFILES_DOCKER true
WORKDIR /home/sirius/dotfiles

# Install zsh config
RUN bash ./zsh/install.sh

# Install vim config
RUN pip3 install --user pynvim
RUN zsh ./vim/install.sh

# Install tmux config
RUN zsh ./tmux-install.sh

WORKDIR /home/sirius

# Install other packages

# rg
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb && \ 
        sudo dpkg -i ripgrep_11.0.1_amd64.deb && \
        rm ripgrep_11.0.1_amd64.deb

# fd
RUN curl -LO https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb && \
        sudo dpkg -i fd_7.3.0_amd64.deb && \
        rm fd_7.3.0_amd64.deb

ENTRYPOINT /bin/zsh
