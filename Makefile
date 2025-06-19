# -------- options-greeks-api Makefile --------
PROJECT    := options-greeks-api
IMG        := $(PROJECT):local              # local tag
PORT       := 8000                          # container port
KIND_NAME  := dev                           # kind cluster name
DOCKER_BUILDKIT ?= 1

help:       ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

lint:       ## Ruff / Black / etc. (only if Python)
	pip install -q ruff black
	ruff src tests
	black --check src tests

test:       ## Run pytest suite
	pip install -q pytest
	pytest -q

build:      ## Build Docker image
	@echo "▶ Building $(IMG)"
	DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) docker build -t $(IMG) .

run: build  ## Build & run locally on $(PORT)
	docker run --rm -p $(PORT):$(PORT) $(IMG)

kind-load: build ## Load image into kind (no push)
	kind load docker-image $(IMG) --name $(KIND_NAME)

skaffold:   ## Live-reload dev loop (kind/Colima)
	skaffold dev -p dev

clean:      ## Remove local image
	-docker rmi $(IMG)

ci: lint test build  ## Lint+Test+Build (used in GitHub Actions)

.PHONY: help lint test build run kind-load skaffold clean ci
