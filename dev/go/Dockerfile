FROM sirius8117/dotfiles:latest
MAINTAINER Taishi Nojima

# Additions for godev
ENV GOPKG_TAR go1.12.3.linux-amd64.tar.gz
ENV GO_DOWNLOAD_DIR /usr/local/src
ENV GO_INSTALL_DIR /usr/local
ENV GOPATH /home/sirius/go

# download
RUN sudo wget -q https://dl.google.com/go/$GOPKG_TAR -O $GO_DOWNLOAD_DIR/$GOPKG_TAR
# extract
RUN sudo tar -xzf $GO_DOWNLOAD_DIR/$GOPKG_TAR -C $GO_DOWNLOAD_DIR
# install
RUN sudo mv $GO_DOWNLOAD_DIR/go $GO_INSTALL_DIR
RUN mkdir -p $GOPATH/bin $GOPATH/pkg $GOPATH/src

RUN echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' > /home/sirius/zshrc.override
RUN echo 'export GOPATH=$HOME/go' >> /home/sirius/zshrc.override
RUN echo 'export GOBIN=$HOME/go/bin' >> /home/sirius/zshrc.override

RUN zsh -ic "go get -u github.com/stamblerre/gocode"
RUN zsh -ic "nvim --headless +GoInstallBinaries +qa"

