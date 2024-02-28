mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(abspath $(patsubst %/,%,$(dir $(mkfile_path))))

run:
	docker run --volume ${current_dir}:/src -p 1313:1313 ghcr.io/hugomods/hugo:go-git-0.123.4 hugo server --environment development --bind 0.0.0.0

lint:
	npx prettier . --write

install:
	npm install
