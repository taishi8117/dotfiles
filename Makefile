DOTFILES_EXCLUDES	:= .DS_Store .git .gitmodules .travis.yml
DOTFILES_TARGET		:= $(wildcard .??*) 
DOTFILES_DIR			:= $(PWD)
DOTFILES_FILES		:= $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

.PHONY: deploy init clean

deploy:
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init:
	@$(foreach val, $(wildcard ./etc/init/*.sh), bash $(val);)

clean: ## Remove the dot files and this repo
	@echo 'Remove dot files in your home directory...'
	@$(foreach val, $(DOTFILES_FILES), rm -vrf $(HOME)/$(val);)
