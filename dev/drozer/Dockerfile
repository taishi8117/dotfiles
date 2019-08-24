FROM sirius8117/dotfiles:py27

# Sirius Lab dotfiles image: Drozer.
# https://github.com/mwrlabs/drozer
#

# Install JDK 1.7
# Follow: https://askubuntu.com/questions/1034387/how-can-i-install-jdk7-on-ubuntu-18-04-lts-64bit
RUN wget https://www.dropbox.com/s/9cbsn5j5bfp35ht/jdk-7u80-linux-x64.tar.gz?dl=1 \
        -O /tmp/jdk-7u80-linux-x64.tar.gz -q
RUN sudo mkdir -p /usr/local/java && \
        sudo tar xvzf /tmp/jdk-7u80-linux-x64.tar.gz -C /usr/local/java

USER root
ADD jdk7_profile /tmp/jdk7_profile
RUN cat /tmp/jdk7_profile >> /etc/profile

RUN update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk1.7.0_80/bin/java" 1 \
        && update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk1.7.0_80/bin/javac" 1 \
        && update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jdk1.7.0_80/bin/javaws" 1 \
        && update-alternatives --set java /usr/local/java/jdk1.7.0_80/bin/java \
        && update-alternatives --set javac /usr/local/java/jdk1.7.0_80/bin/javac \
        && update-alternatives --set javaws /usr/local/java/jdk1.7.0_80/bin/javaws

USER sirius
WORKDIR /home/sirius

RUN sudo apt-get update && \
        sudo apt-get install python-protobuf python-openssl python-twisted protobuf-compiler -y
RUN git clone https://github.com/mwrlabs/drozer

WORKDIR /home/sirius/drozer
RUN make deb
RUN sudo dpkg -i dist/drozer_*.deb


WORKDIR /home/sirius
