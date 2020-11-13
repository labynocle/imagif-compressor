.DEFAULT_GOAL := help

IMAGIF_IMAGE        = labynocle/imagif-compressor
IMAGIF_VERSION_FILE = version.txt
IMAGIF_VERSION      = v`cat $(IMAGIF_VERSION_FILE)`
DOCKERHUB_REGISTRY  = docker.io

################################################################################

##
## Misc commands
## -----
##

list: ## Generate basic list of all targets
	@grep '^[^\.#[:space:]].*:' Makefile | \
		grep -v "=" | \
		cut -d':' -f1

help: ## Makefile help
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | \
		sed -e 's/\[32m##/[33m/'

get-version: ## Display current IMAGIF version
	@echo $(IMAGIF_VERSION)

set-version: ## Set NEW_VERSION as the new IMAGIF version
	@if [ -z "$(NEW_VERSION)" ]; then \
		echo "Usage: make set-version NEW_VERSION=X.Y.Z" && \
		exit 1; \
	fi
	@echo "$(NEW_VERSION)" | sed -e "s/^v//g" > $(IMAGIF_VERSION_FILE)

##
## Build commands
## -----
##

docker-build: ## Build the imagif-compressor docker image
	docker build -t ${IMAGIF_IMAGE}:${IMAGIF_VERSION} .

##
## Docker commands
## -----
##

push-to-dockerhub:  ## Push production image to dockerhub
	for tag in ${IMAGIF_VERSION} ${IMAGIF_IMAGE_MORE_TAGS}; do \
		docker tag ${IMAGIF_IMAGE}:${IMAGIF_VERSION} ${DOCKERHUB_REGISTRY}/${IMAGIF_IMAGE}:$${tag} && \
		docker push ${DOCKERHUB_REGISTRY}/${IMAGIF_IMAGE}:$${tag}; \
	done
