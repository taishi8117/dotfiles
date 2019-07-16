DOTFILES_DIR			:= $(PWD)

.PHONY: fetch tmux_install zsh_install vim_install clean update install

fetch:
	@echo '[+] Fetching the repository...'
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

tmux_install:
	@echo '[+] Setting up tmux...'
	$(DOTFILES_DIR)/tmux-install.sh

zsh_install:
	@echo '[+] Setting up zsh...'
	$(DOTFILES_DIR)/zsh/install.sh

vim_install:
	@echo '[+] Setting up vim...'
	$(DOTFILES_DIR)/vim/install.sh


update: fetch deploy exec_shell

install: fetch tmux_install zsh_install vim_install

clean: ## Remove the dot files and this repo
	@echo 'Cleaning dotfiles...'
	rm -rf $(HOME)/.tmux*
	$(DOTFILES_DIR)/zsh/cleanup.sh
	$(DOTFILES_DIR)/vim/cleanup.sh
