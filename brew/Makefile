.PHONY: all Brewfile

all:
	@brew update --quiet
	@brew bundle check --quiet || brew bundle install --quiet
	@brew bundle cleanup --quiet --force
	@brew pin tmux

Brewfile:
	@brew bundle dump --force --no-go
