FROM ubuntu:18.04
MAINTAINER Taishi Nojima

# Install dependencies
RUN ./dep/ubuntu.sh

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

WORKDIR /home/sirius/dotfiles

# Install zsh config
RUN bash ./zsh/install.sh

# Install vim config
RUN pip3 install --user pynvim
RUN zsh ./vim/install.sh
RUN nvim --headless +UpdateRemotePlugins +qa

# Install tmux config
RUN zsh ./tmux-install.sh
