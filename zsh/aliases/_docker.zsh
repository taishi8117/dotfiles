# Sirius Lab dotfiles Docker images
alias godev="docker run --rm -i -t --entrypoint=/bin/zsh \
    -v ~/.ssh/id_rsa.pub:/home/sirius/.ssh/id_rsa.pub:ro \
    -v ~/.ssh/id_rsa:/home/sirius/.ssh/id_rsa:ro \
    -v ~/.ssh/known_hosts:/home/sirius/.ssh/known_hosts \
    -v ~/.gitconfig:/home/sirius/.gitconfig:ro \
    sirius8117/dotfiles:godev"

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
