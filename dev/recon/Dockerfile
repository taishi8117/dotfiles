FROM sirius8117/dotfiles:kali

RUN apt-get update && apt-get install -y \
        python-pip \
        kali-linux-core \
        tshark \
        amass \
        gobuster \
        libldns-dev \
        masscan \
        nmap \
        brutespray \
        eyewitness \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install shodan 

RUN mkdir -p /tools
WORKDIR /tools

COPY ./subfinder /tools/subfinder

# Install DomLink, useful for tld discovery
RUN git clone https://github.com/vysecurity/DomLink
RUN pip install -r DomLink/requirements.txt

# Install massdns
RUN git clone https://github.com/blechschmidt/massdns.git
WORKDIR /tools/massdns
RUN make
