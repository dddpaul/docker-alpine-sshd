.PHONY: all build release

IMAGE=dddpaul/alpine-sshd

all: build

build:
	@docker build --tag=${IMAGE} .

debug: build
	@docker run -it --entrypoint=sh ${IMAGE}

run: build
	@docker run --rm --name sshd -p 10022:22 -v ${PWD}/users.csv:/etc/ssh/users.csv -e SSHD_ALLOW_TCP_FORWARDING=yes -e SSHD_CLIENT_ALIVE_INTERVAL=30 ${IMAGE}

release: build
	@echo "Tag image with version $(version)"
	@docker tag ${IMAGE} ${IMAGE}:$(version)

push: release
	@docker push ${IMAGE}
	@docker push ${IMAGE}:$(version)
