.ONESHELL:

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

.DEFAULT:
build:
	docker build --rm --progress=plain --file Dockerfile --tag themakers/protoc:latest context

run: build
	docker run --rm -it themakers/protoc:latest

publish: build
	docker image push themakers/protoc:latest
