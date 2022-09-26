# After changing BASE_IMAGE_NAME, make sure to update .env
BASE_IMAGE_NAME=myproject
POETRY_CACHE_DIR=`command -v poetry >/dev/null 2>&1 && poetry config cache-dir || echo ".poetry"`

.PHONY: env build deps clear-build export-image import-image run run-prod stop bash sudo-bash run-bash run-sudo-bash lint test mypy

# Building and dependencies
env:
	if [ ! -f ".env" ]; then echo "BASE_IMAGE_NAME=${BASE_IMAGE_NAME}\nPOETRY_CACHE_DIR=${POETRY_CACHE_DIR}" > .env; fi
build: env
	docker-compose build \
		--build-arg GROUP_ID=`id -g` \
		--build-arg USER_ID=`id -u`
deps: build
	docker-compose run --rm jupyter poetry install
clear-build:
	docker-compose rm
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml rm

# Docker image export/import
export-image: env
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml build \
		--build-arg GROUP_ID=1000 \
		--build-arg USER_ID=1000
	mkdir -p images
	docker save -o "images/${BASE_IMAGE_NAME}-prod.image" "${BASE_IMAGE_NAME}-prod"
import-image:
	docker load --input "images/${BASE_IMAGE_NAME}-prod.image"

# Running the application
run: deps
	docker-compose up
run-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
stop:
	docker-compose stop

# Starting a shell in a Docker container
bash:
	docker-compose exec jupyter /bin/bash
sudo-bash:
	docker-compose exec --user root jupyter /bin/bash
run-bash:
	docker-compose run --rm jupyter /bin/bash
run-sudo-bash:
	docker-compose run --user root --rm jupyter /bin/bash

# Python module utilities
lint:
	docker-compose run --rm jupyter poetry run flake8 lib/*
test:
	docker-compose run --rm jupyter poetry run pytest \
		--cov="lib" \
		--cov-report="html:test/coverage" \
		--cov-report=term ;
mypy:
	docker-compose run --rm jupyter poetry run mypy lib/*
