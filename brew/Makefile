.PHONY: all Brewfile

all:
	@brew update --quiet
	@brew bundle check --quiet || brew bundle install --quiet
	@brew bundle cleanup --quiet --force

Brewfile:
	@brew bundle dump --force --no-go
