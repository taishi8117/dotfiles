FROM ubuntu:18.04
MAINTAINER Taishi Nojima

RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update
RUN apt-get install git sudo zsh tmux neovim python3 python3-dev python3-pip wget gawk curl -y

# Create user
RUN useradd -m -s /bin/zsh sirius
RUN usermod -aG sudo sirius
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

# Install zplug
RUN git clone https://github.com/taishi8117/zplug $ZPLUG_HOME

WORKDIR /home/sirius/dotfiles

# Install zsh config
ENV ZSHRC /home/sirius/.zshrc
ENV ZSHENV /home/sirius/.zshenv

RUN ln -sfn /home/sirius/dotfiles/zsh/zshrc $ZSHRC
RUN ln -sfn /home/sirius/dotfiles/zsh/zshenv $ZSHENV
RUN zsh -ic "echo 'hello dotfiles!'"

# Install vim config
RUN pip3 install --user pynvim
RUN zsh ./vim/install.sh
RUN nvim --headless +UpdateRemotePlugins +qa

# Install tmux config
RUN zsh ./tmux-install.sh
