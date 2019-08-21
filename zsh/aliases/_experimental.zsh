alias ssh-password-only='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'

# Adding https://gist.github.com/jessesquires/d0f3fc99be8208394a450ce86443ce7d
git config --global alias.smartlog "log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%C(cyan)%s%n%Creset'"

git config --global alias.sl '!git smartlog'

function wut() {
  curl --silent cheat.sh/$1 | less
}

alias mitmproxy='mitmproxy --set console_palette=lowdark'
