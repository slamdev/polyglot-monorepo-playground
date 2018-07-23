SHELL = /bin/bash

e = dev
# these variables will be accesible from sub-makefiles
export ENVIRONMENT := ${e}
export PROJECT := playground

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
	kubectl rollout status deploy $(1) -n$(2);
endef
export rollout_status = $(value _rollout_status)

##
## Get rollout status of all deployments in namespace
##
define _rollout_statuses
	$(eval DEPLOYS := `kubectl get deploy -o jsonpath='{.items[*].metadata.name}' -n$(1)`)
	@for app in $(DEPLOYS); do\
        set -e;\
        kubectl rollout status deploy $$app -n$(1);\
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
