PROFILE_DIR := profile
PHOTOS_DIR := photos
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)
ifndef DOCKER_COMPOSE
    DOCKER_COMPOSE := docker compose
endif
export PUID=$(shell id -u)
export PGID=$(shell id -g)

.PHONY: auth
.ONESHELL:
auth:
	mkdir -p ${PROFILE_DIR}
	mkdir -p ${PHOTOS_DIR}
	${DOCKER_COMPOSE} up -d --build auth
	echo "giving VNC time to be ready, please wait..."
	sleep 2

	echo "Open chrome by using the open-chrome.sh script then close that browser window (inside the container) before continuing"
	read -p  "Press any key after you have authenticated in your browser at http://<hostname>:6080 like http://localhost:6080"

	${DOCKER_COMPOSE} down

.PHONY: build
build:
	${DOCKER_COMPOSE} build

.PHONY: test
test: build
	${DOCKER_COMPOSE} -f docker-compose.yml -f docker-compose.test.yml run --rm gphotos-sync
