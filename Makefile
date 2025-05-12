DATE_TAG := $(shell date +%Y%m%d)
BACKEND_IMAGE_NAME := backend
FRONTEND_IMAGE_NAME := frontend
POETRY_IMAGE_NAME := poetry-builder
UV_IMAGE_NAME := uv-builder
WORKER_IMAGE_NAME := worker
.PHONY: all
all: build

.PHONY: buildah
buildah:
	buildah bud \
	"--storage-driver=overlay" \
	"--ssh=default=$(HOME)/.ssh/current/id_rsa_infra" \
	"--target=$(BACKEND_IMAGE_NAME)" \
	"--format=oci" \
	-f "Dockerfile" \
	-t "$(BACKEND_IMAGE_NAME):latest" \
	"."

.PHONY: build-poetry
build-poetry:
	@echo "Building $(POETRY_IMAGE_NAME)..."
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target $(POETRY_IMAGE_NAME) \
		-t $(POETRY_IMAGE_NAME):latest \
		-t $(POETRY_IMAGE_NAME):$(DATE_TAG) \
		-f Dockerfile .

.PHONY: build-worker
build-worker:
	@echo "Building $(WORKER_IMAGE_NAME)..."
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target $(WORKER_IMAGE_NAME)-dev \
		-t $(WORKER_IMAGE_NAME):latest \
		-t $(WORKER_IMAGE_NAME):$(DATE_TAG) \
		-f Dockerfile .


.PHONY: uv
uv:
	@echo "Building $(UV_IMAGE_NAME)..."
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target $(UV_IMAGE_NAME) \
		-t $(UV_IMAGE_NAME):latest \
		-t $(UV_IMAGE_NAME):$(DATE_TAG) \
		-f Dockerfile .
	
.PHONY: build-backend
build-backend:
	echo "Building $(BACKEND_IMAGE_NAME)..." && \
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target $(BACKEND_IMAGE_NAME) \
		-t $(BACKEND_IMAGE_NAME):latest \
		-t $(BACKEND_IMAGE_NAME):$(DATE_TAG) \
		-f Dockerfile .

.PHONY: build-frontend
build-frontend:
	@echo "Building $IMAGE_NAME..."
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target $(FRONTEND_IMAGE_NAME) \
		-t $(FRONTEND_IMAGE_NAME):latest \
		-t $(FRONTEND_IMAGE_NAME):$(DATE_TAG) \
		-f Dockerfile .

.PHONY: frontend-builder
frontend-builder:
	@echo "Building frontend-builder..."
	docker build \
		--ssh default=$(HOME)/.ssh/current/id_rsa_infra \
		--target frontend-builder \
		-t frontend-builder:latest \
		-t frontend-builder:$(DATE_TAG) \
		-f Dockerfile .

.PHONY: clean
clean:
	@echo "Cleaning up Docker images..."
	docker rmi $(IMAGE_NAME):latest $(FULL_IMAGE_NAME) || true
	docker rmi $(DOCKER_REGISTRY)/$(FULL_IMAGE_NAME) || true
	docker rmi $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest || true


.PHONY: help
help:
	@echo "Available targets:"
	@echo "  buildah  - Build the backend image using buildah"
	@echo "  python   - Build the Python venv"
	@echo "  build-backend - Build the backend image"
	@echo "  build-frontend - Build the frontend image"
	@echo "  clean  - Remove local Docker images"
	@echo "  help   - Show this help message"
