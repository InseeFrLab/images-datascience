# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
.PHONY: docs help test

# Use bash for inline if-statements in arch_patch target
SHELL:=bash
OWNER?=jupyter
# Need to list the images in build dependency order
# All of the images
ALL_IMAGES:= \
    base \
	python \
	jupyter 

# Enable BuildKit for Docker build
export DOCKER_BUILDKIT:=1

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@echo "jupyter/docker-stacks"
	@echo "====================="
	@echo "Replace % with a stack directory name (e.g., make build/base)"
	@echo
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build/%: DOCKER_BUILD_ARGS?=
build/%: ## build the latest image for a stack using the system's architecture
	@echo "::group::Build $(OWNER)/$(notdir $@) (system's architecture)"
	docker build $(DOCKER_BUILD_ARGS) --rm --force-rm -t $(OWNER)/$(notdir $@):latest ./$(notdir $@) --build-arg OWNER=$(OWNER)
	@echo -n "Built image size: "
	@docker images $(OWNER)/$(notdir $@):latest --format "{{.Size}}"
	@echo "::endgroup::"
build-all: $(foreach I, $(ALL_IMAGES), build/$(I)) ## build all stacks

define make_test
	if [  -z "$(1)" ]; \
	then echo "no test"; \
	else \
		echo "test";  \
		container-structure-test.exe test --image $(2)/$(3):latest --config $(1);  \
	fi
endef

test/%: ## run tests against an image
	@echo "::group::test/$(OWNER)/$(notdir $@)"
	$(eval SOURCES := $(wildcard ./$(notdir $@)/*tests.yaml))
	$(call make_test,$(SOURCES),$(OWNER),$(notdir $@))
	@echo "::endgroup::"
test-all: $(foreach I, $(ALL_IMAGES), test/$(I)) ## test all images


run-jupyter-lab: ## launch image jupyter local as user onyxia
	docker run -t -i -p 8888:8888 --user onyxia --env USERNAME=test --env NB_USER=toto --rm $(OWNER)/jupyter start-onyxia.sh jupyter lab --no-browser --ip '0.0.0.0' --LabApp.token='password'


run-jupyter-lab-bash/%: ## launch bash in image specified
	docker run -t -i -p 8888:8888 --user onyxia  --rm --env NB_USER=test $(OWNER)/$(notdir $@) bash