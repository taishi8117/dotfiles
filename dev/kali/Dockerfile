FROM kalilinux/kali-linux-docker

RUN apt-get update && apt-get install -y \
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

# Locale settings: 
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8   
ENV TERM xterm-256color

ADD . /root/dotfiles
ENV HOME /root
ENV ZPLUG_HOME /root/.zplug
ENV DOTFILES_DOCKER true
WORKDIR /root/dotfiles

# Install zsh config
RUN bash ./zsh/install.sh

# Install vim config
RUN pip3 install pynvim
RUN zsh ./vim/install.sh

# Install tmux config
RUN zsh ./tmux-install.sh

# rg
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb && \ 
        dpkg -i ripgrep_11.0.1_amd64.deb && \
        rm ripgrep_11.0.1_amd64.deb

# fd
RUN curl -LO https://github.com/sharkdp/fd/releases/download/v7.3.0/fd_7.3.0_amd64.deb && \
        dpkg -i fd_7.3.0_amd64.deb && \
        rm fd_7.3.0_amd64.deb

ENTRYPOINT /bin/zsh
