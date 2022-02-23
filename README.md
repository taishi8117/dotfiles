# dotfiles
[![Build Status](https://travis-ci.org/taishi8117/dotfiles.svg?branch=master)](https://travis-ci.org/taishi8117/dotfiles)

## Installation

To install on a Ubuntu 18.04 instance, clone this repository in your home directory and
run `make ubuntu`. Note that the dotfiles directory should live in the root of your
home directory, otherwise it may not function properly.
```
cd ${HOME}
git clone https://github.com/taishi8117/dotfiles
make ubuntu
```

Then, change the default shell to zsh using `chsh`.

Installation on darwin (macOS) should also work out of box, but run the following
instead of `make ubuntu`.
```
~/dotfiles/dep/darwin.sh  # to install dependencies for darwin
make install
```

## Running on Docker

This dotfiles environment is available as a Docker image
hosted on [Docker Hub](https://hub.docker.com/r/sirius8117/dotfiles/tags).
Run `docker pull sirius8117/dotfiles:latest` to retrieve the image.
Alternatively, you can build the image locally with
`docker built -t sirius8117/dotfiles ~/dotfiles`.

## On-Demand Development Environment with Docker

This repository also hosts Docker images useful for development in some
specific environments. It currently supports golang, tensorflow and frida,
but I plan to add more in the future. These images are based on
`sirius8117/dotfiles:latest` and have the corresponding runtime environments
and configurations already preinstalled.

Combined with aliases defined in `~/dotfiles/zsh/aliases/_docker.zsh`, you can
create a throwaway, on-demand, clean development environment with just
a single command. For example, running `godev` will automatically start a new
container based on `sirius8117/dotfiles:godev`, mount the current directory inside
the container, and pop you a familiar Zsh shell.

As before, you can pull the images from Docker Hub with the following tags, or
you can build them locally if you prefer.

* [sirius8117/dotfiles:godev](https://hub.docker.com/r/sirius8117/dotfiles/tags)
* [sirius8117/dotfiles:tensorflow](https://hub.docker.com/r/sirius8117/dotfiles/tags)
* [sirius8117/dotfiles:frida](https://hub.docker.com/r/sirius8117/dotfiles/tags)
