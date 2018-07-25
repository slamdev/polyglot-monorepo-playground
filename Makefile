SHELL = /bin/bash

##
## Command-line args
##
e = dev
b =
##
## Global variables
##
PROJECT := playground
export PROJECT
BRANCH := $(b)
export BRANCH
ifdef BRANCH
	ENVIRONMENT := review
	NAMESPACE := $(PROJECT)-$(ENVIRONMENT)-$(BRANCH)
else
	ENVIRONMENT := $(e)
	NAMESPACE := $(PROJECT)-$(ENVIRONMENT)
endif
export ENVIRONMENT
export NAMESPACE

MODULES := etc ops infra js java
CLEAN_TARGETS := $(foreach m,$(MODULES),clean-$(m))
CHECK_TARGETS := $(foreach m,$(MODULES),check-$(m))
BUILD_TARGETS := $(foreach m,$(MODULES),build-$(m))
DEPLOY_TARGETS := $(foreach m,$(MODULES),deploy-$(m))
# special cases
MODULE_java := Makefile.java.mk
MODULE_js := Makefile.js.mk

.PHONY: help
help:
	@echo ""
	@echo "Available tasks:"
	@echo "    clean              run clean task for all modules"
	@echo "    clean-%            run clean task for a specific modules"
	@echo "    check              run check task for all modules"
	@echo "    check-%            run check task for a specific modules"
	@echo "    build              run build task for all modules"
	@echo "    build-%            run build task for a specific modules"
	@echo "    deploy             run deploy task for all modules"
	@echo "    deploy-%           run deploy task for a specific modules"
	@echo "Envinronment can be passed via e=[env] argument, e.g.:"
	$(call colorecho,"    make deploy-java e=prod")
	@echo "Default environment is [dev]"
	@echo ""

.PHONY: clean-%
clean-%:
	$(call exec_module,$@)

.PHONY: clean
clean: $(CLEAN_TARGETS)

.PHONY: check-%
check-%:
	$(call exec_module,$@)

.PHONY: check
check: $(CHECK_TARGETS)

.PHONY: build-%
build-%: check-%
	$(call exec_module,$@)

.PHONY: build
build: $(BUILD_TARGETS)

.PHONY: deploy-%
deploy-%: build-%
	$(call exec_module,$@)

.PHONY: deploy
deploy: $(DEPLOY_TARGETS)

.PHONY: create-reviewapp
create-reviewapp: deploy-infra deploy-js deploy-java

.PHONY: drop-reviewapp
drop-reviewapp:
	kubectl delete ns $(NAMESPACE)

##
## Run make COMMAND -f MAKEFILE for special cases
## or make COMMAND -C DIR for general modules
##
define exec_module
	$(eval COMMAND := $(firstword $(subst -, ,$(1))))
	$(eval CURRENT_MODULE := $(lastword $(subst -, ,$(1))))
	$(eval SPECIAL_MAKEFILE := $(MODULE_$(CURRENT_MODULE)))
	$(call colorecho,"Running [$(COMMAND)] command in [$(CURRENT_MODULE)] module for [$(ENVIRONMENT)] environment")
	@if [ "$(SPECIAL_MAKEFILE)" = "" ]; then\
		$(MAKE) $(COMMAND) -C $(CURRENT_MODULE);\
	else\
		$(MAKE) $(COMMAND) -f $(SPECIAL_MAKEFILE);\
	fi
endef

##
## Echo text in cyan color
##
define colorecho
	@tput setaf 6
	@echo $1
	@tput sgr0
endef

##
## Get rollout status of single deployment in namespace
##
define _rollout_status
	set -e;\
	kubectl rollout status deploy $(1) -n$(NAMESPACE);
endef
export rollout_status = $(value _rollout_status)

##
## Get rollout status of all deployments in namespace
##
define _rollout_statuses
	$(eval DEPLOYS := `kubectl get deploy -o jsonpath='{.items[*].metadata.name}' -n$(NAMESPACE)`)
	for app in $(DEPLOYS); do\
        set -e;\
        kubectl rollout status deploy $$app -n$(NAMESPACE);\
    done
endef
export rollout_statuses = $(value _rollout_statuses)

##
## Build manifest via kustomize and validate it via kubectl
##
define _validate_minifest
	set -e;\
	kustomize build $(1) | kubectl apply --dry-run=true --validate=true -f -;
endef
export validate_minifest = $(value _validate_minifest)

##
## Get the newest image id by name from skaffold.yaml, tag it and push it
##
define _tag_n_push
	$(eval IMAGE_NAME := `sed -n -e 's/^.*imageName: //p' $(1)/skaffold.yaml`)
	set -e;\
	docker tag $$(docker images -q $(IMAGE_NAME) | head -n 1) $(IMAGE_NAME):$(2);\
	docker push $(IMAGE_NAME):$(ENVIRONMENT);
endef
export tag_n_push = $(value _tag_n_push)

##
## If is review app, generate k8s manifest in build dir replacing the namespace
##
define _prepare_review_app_if_needed
	if [ -n "$(BRANCH)" ]; then\
		mkdir -p $(1)/build; \
		kustomize build $(1)/$(2) \
		| sed 's/\(namespace: \).*/\1$(NAMESPACE)/g' \
		| tr '\n' '\f' \
		| sed "s/\(.*kind: Namespace$$(printf '\f')metadata:$$(printf '\f')  name: \)[[:print:]]*\(.*\)/\1$(NAMESPACE)\2/g" \
		| tr '\f' '\n' \
		> $(1)/build/review-app.yaml; \
	fi
endef
export prepare_review_app_if_needed = $(value _prepare_review_app_if_needed)
