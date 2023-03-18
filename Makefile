# Ensure Make is run with bash shell as some syntax below is bash-specific
SHELL             := /usr/bin/env bash
ROOT_DIR          := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PLATFORM          ?= linux/amd64,linux/arm64
RPM_VERSION       := 12.1.5

.PHONY: build-rpm
build-rpm:
	@rm -rf rpms output
	@mkdir -p rpms
	DOCKER_BUILDKIT=1 docker buildx build \
		--ulimit nofile=1024:1024 \
		--platform $(PLATFORM) \
		-f $(ROOT_DIR)/Dockerfile \
		--output type=local,dest=$(ROOT_DIR)/output \
		$(ROOT_DIR)
	@mv output/*/* rpms
	@rm -rf output
	tree rpms
