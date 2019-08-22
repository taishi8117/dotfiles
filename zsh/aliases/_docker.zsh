# Sirius Lab dotfiles Docker images

function godev() {
    dirname=${PWD##*/}
    docker run --rm -i -t --entrypoint=/bin/zsh \
        -v `pwd`:/${dirname} -w /${dirname} \
        -v ~/.ssh/id_rsa.pub:/home/sirius/.ssh/id_rsa.pub:ro \
        -v ~/.ssh/id_rsa:/home/sirius/.ssh/id_rsa:ro \
        -v ~/.ssh/known_hosts:/home/sirius/.ssh/known_hosts \
        -v ~/.gitconfig:/home/sirius/.gitconfig:ro \
        sirius8117/dotfiles:godev
}

function dockerdev() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/zsh \
        -v `pwd`:/${dirname} -w /${dirname} \
        -v ~/.ssh/id_rsa.pub:/home/sirius/.ssh/id_rsa.pub:ro \
        -v ~/.ssh/id_rsa:/home/sirius/.ssh/id_rsa:ro \
        -v ~/.ssh/known_hosts:/home/sirius/.ssh/known_hosts \
        -v ~/.gitconfig:/home/sirius/.gitconfig:ro \
        sirius8117/dotfiles
}

function fridahere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/zsh \
        --privileged \
        -v `pwd`:/${dirname} -w /${dirname} \
        sirius8117/dotfiles:frida
}

function mitmhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/home/sirius/dotfiles/mitmproxy/start-mitmproxy.sh \
        -p 8080:8080 \
        -v ~/.mitmproxy:/home/sirius/.mitmproxy \
        -v `pwd`:/${dirname} -w /${dirname} \
        sirius8117/dotfiles:mitmproxy
}


# Referenced from: https://blog.ropnop.com/docker-for-pentesters/
alias dockerzsh="docker run --rm -i -t --entrypoint=/bin/zsh"
alias dockerbash="docker run --rm -i -t --entrypoint=/bin/bash"
alias dockersh="docker run --rm -i -t --entrypoint=/bin/sh"

function dockerzshhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/zsh -v `pwd`:/${dirname} -w /${dirname} "$@"
}
function dockerbashhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}
function dockershhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}
