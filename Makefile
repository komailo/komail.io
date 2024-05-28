mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

run:
	npm exec -- hugo --environment development server --bind 0.0.0.0

lint:
	npx prettier . --write

install:
	npm install
	git submodule update --init --recursive
