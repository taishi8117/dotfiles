alias ssh-password-only='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'

# Adding https://gist.github.com/jessesquires/d0f3fc99be8208394a450ce86443ce7d
git config --global alias.smartlog "log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%C(cyan)%s%n%Creset'"

git config --global alias.sl '!git smartlog'

function wut() {
  curl --silent cheat.sh/$1 | less
}

function feat() {
    dirname=${PWD##*/}
    git add . && git commit -m "feat(${dirname}): $1"
}


function chore() {
    dirname=${PWD##*/}
    git add . && git commit -m "chore(${dirname}): $1"
}

function fix() {
    dirname=${PWD##*/}
    git add . && git commit -m "fix(${dirname}): $1"
}

alias grh='git reset HEAD~'
alias gsl='git sl'

alias vimplug='vim ~/dotfiles/vim/rc/dein.toml'
