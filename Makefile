DOTFILES_EXCLUDES	:= .DS_Store .git .gitmodules .travis.yml
DOTFILES_TARGET		:= $(wildcard .??*) 
DOTFILES_DIR			:= $(PWD)
DOTFILES_FILES		:= $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

.PHONY: deploy init clean update install

deploy:
	@echo '[+] Starting to deploy dotfiles to home directory...'
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init:
	@$(foreach val, $(wildcard ./etc/init/*.sh), bash $(val);)

update:
	@echo '[+] Updating the repository...'
	git pull origin master
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: update deploy init
	@exec $$SHELL

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@$(foreach val, $(DOTFILES_FILES), rm -vrf $(HOME)/$(val);)
