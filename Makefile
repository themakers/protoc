.ONESHELL:

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

.DEFAULT:
build:
	# docker buildx create --use --name themakers
	docker buildx build --rm --progress=plain --builder=themakers --platform linux/amd64,linux/arm64 --file Dockerfile --tag themakers/protoc:latest context

run: build
	docker run --rm -it themakers/protoc:latest /bin/bash

publish: build
	docker image push themakers/protoc:latest
