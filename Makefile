.ONESHELL:

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

.DEFAULT:
build:
	docker build --rm \
		--progress=plain \
		--tag themakers/protoc:local \
		--target final \
		- < Dockerfile


run: build
	docker run --rm -it themakers/protoc:local /bin/sh

#publish: build
#	docker image push themakers/protoc:latest
