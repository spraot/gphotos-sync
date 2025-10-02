PROFILE_DIR := profile
PHOTOS_DIR := photos
DOCKER_COMPOSE_OLD := $(shell command -v docker-compose 2> /dev/null)
DOCKER_COMPOSE := $(shell docker compose 2> /dev/null)
ifdef DOCKER_COMPOSE
    DOCKER_COMPOSE := docker compose
else
	DOCKER_COMPOSE := ${DOCKER_COMPOSE_OLD}
endif
export PUID=$(shell id -u)
export PGID=$(shell id -g)

.PHONY: auth
.ONESHELL:
.SILENT:
auth:
	mkdir -p ${PROFILE_DIR}
	mkdir -p ${PHOTOS_DIR}
	${DOCKER_COMPOSE} down -v
	${DOCKER_COMPOSE} up --build auth && echo "giving VNC time to be ready, please wait..."
	sleep 2

	echo "Open chrome by using the open-chrome.sh script then close that browser window (inside the container) before continuing"
	read -p  "Press any key after you have authenticated in your browser at http://<hostname>:6080 like http://localhost:6080 (ctrl-click to open it in most terminals)"

	${DOCKER_COMPOSE} down

.PHONY: build
build:
	${DOCKER_COMPOSE} build

.PHONY: test
test: build
	${DOCKER_COMPOSE} -f docker-compose.yml -f docker-compose.test.yml run --rm gphotos-sync
