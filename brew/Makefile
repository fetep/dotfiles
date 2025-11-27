.PHONY: all

all:
	@brew update --quiet
	@brew bundle check --quiet || brew bundle install --quiet
	@brew bundle cleanup --quiet --force
