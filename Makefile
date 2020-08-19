.PHONY: all build release

IMAGE=dddpaul/alpine-sshd
VERSION=1.8

all: build

build:
	@docker build --tag=${IMAGE} .

debug: build
	@docker run -it --entrypoint=sh ${IMAGE}

run: build
	@docker run --rm --name sshd -p 10022:22 -v ${PWD}/users.csv:/etc/ssh/users.csv ${IMAGE}

release: build
	@docker build --tag=${IMAGE}:${VERSION} .

deploy: release
	@docker push ${IMAGE}
	@docker push ${IMAGE}:${VERSION}
