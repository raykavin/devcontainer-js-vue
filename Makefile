IMAGE_NAME ?= ${PROJECT_NAME}
VERSION ?= 1.0.0

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build           Run build.sh script (uses IMAGE_NAME and VERSION)"
	@echo "  deploy          Run deploy.sh script (uses IMAGE_NAME and VERSION)"
	@echo "  test            Run test.sh script"

.PHONY: build
build:
	@scripts/sh/build.sh $(IMAGE_NAME) $(VERSION)

.PHONY: deploy
deploy:
	@scripts/sh/deploy.sh $(IMAGE_NAME) $(VERSION)

.PHONY: test
test:
	@scripts/sh/test.sh
