# dotfiles

# Requirement
* vim
* neovim (python 3)
```
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt-get install neovim
    sudo apt-get install python-dev python-pip python3-dev python3-pip
    pip3 install --user pynvim
```

* python 3
* pygments (for colorize oh-my-zsh, incl. ccat)
* git
* [junegunn/fzf](https://github.com/junegunn/fzf)
    ```
    brew install fzf
    $(brew --prefix)/opt/fzf/install
    ```

    ```
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    ```
* [rg](https://github.com/BurntSushi/ripgrep)
    ```
    brew install ripgrep
    ```

    ```
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb
    sudo dpkg -i ripgrep_0.10.0_amd64.deb
    ```

* gocode
    ```
    go get -u github.com/stamblerre/gocode
    ```
  Restart gocode if autocompletion doesn't work
  Potential [issues](https://github.com/Shougo/deoplete.nvim/issues/818)
