IMAGE_NAME=hello-world-printer
USERNAME=davethepancake
TAG=$(USERNAME)/$(IMAGE_NAME)

.PHONY: deps lint run test docker_build docker_run docker_login docker_push docker_logout

# -----------------------
# Python workflow
# -----------------------

deps:
	pip install -r requirements.txt
	pip install -r test_requirements.txt

lint:
	flake8 hello_world test

run:
	python3 main.py

test:
	PYTHONPATH=. pytest --verbose -s

# -----------------------
# Docker workflow
# -----------------------

docker_build:
	docker build -t $(IMAGE_NAME) .

docker_run: docker_build
	docker run \
		--name $(IMAGE_NAME)-dev \
		-p 5000:5000 \
		-d $(IMAGE_NAME)

# -----------------------
# Docker Hub auth
# -----------------------

docker_login:
	@test -n "$$DOCKER_USERNAME" || (echo "DOCKER_USERNAME is not set" && exit 1)
	@test -n "$$DOCKER_PASSWORD" || (echo "DOCKER_PASSWORD is not set" && exit 1)
	@echo "$$DOCKER_PASSWORD" | docker login -u "$$DOCKER_USERNAME" --password-stdin

docker_logout:
	docker logout

# -----------------------
# Push flow (CI-ready)
# -----------------------

docker_push: docker_build docker_login
	docker tag $(IMAGE_NAME) $(TAG)
	docker push $(TAG)
	$(MAKE) docker_logout
