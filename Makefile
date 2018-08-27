SHELL = /bin/bash

##
## Command-line args
##
e = dev

PROJECT := playground
# If $(e) starts from review, it is a review environment and it will be appended to NAMESPACE
ifeq ($(shell grep -o "^review" <<< $(e)), review)
	ENVIRONMENT := review
	NAMESPACE := $(PROJECT)-$(ENVIRONMENT)-$(shell cut -d "/" -f 2 <<< $(e))
else
	ENVIRONMENT := $(e)
	NAMESPACE := $(PROJECT)-$(ENVIRONMENT)
endif

##
## ETC modules
##

ETC_MODULES := $(shell find etc -name skaffold.yaml -mindepth 2 -maxdepth 2 -exec dirname {} \;)
DEPLOY_ETC_TARGETS := $(foreach m,$(ETC_MODULES),deploy-etc/$(m))

deploy-etc/%:
	@echo "Deploying [$*]"
	$(call pull_images_for_cache,$*)
	cd $* && skaffold build

deploy-etc: $(DEPLOY_ETC_TARGETS)

##
## OPS modules
##

OPS_MODULES := ops/namespace-configuration $(shell find ops -name skaffold.yaml -mindepth 2 -maxdepth 2 -exec dirname {} \; | grep -v 'namespace-configuration')
DEPLOY_OPS_TARGETS := $(foreach m,$(OPS_MODULES),deploy-ops/$(m))

deploy-ops/%:
	@echo "Deploying [$*] to $(NAMESPACE)"
	$(call pull_images_for_cache,$*)
	cd $* && skaffold run
	$(call verify_deployment_status,$*)
	$(call tag_n_push,$*)

deploy-ops: $(DEPLOY_OPS_TARGETS)

##
## INFRA modules
##

INFRA_MODULES := infra/namespace-configuration $(shell find infra -name skaffold.yaml -mindepth 2 -maxdepth 2 -exec dirname {} \; | grep -v 'namespace-configuration')
DEPLOY_INFRA_TARGETS := $(foreach m,$(INFRA_MODULES),deploy-infra/$(m))

deploy-infra/%:
	@echo "Deploying [$*] to $(NAMESPACE)"
ifeq ($(ENVIRONMENT),review)
	$(call prepare_review_app,$*)
endif
	$(call pull_images_for_cache,$*)
	cd $* && skaffold run --profile=$(ENVIRONMENT)
	$(call verify_deployment_status,$*)
	$(call tag_n_push,$*)

deploy-infra: $(DEPLOY_INFRA_TARGETS)

##
## JS modules
##

JS_MODULES := $(shell find apps services -name package.json -mindepth 2 -maxdepth 2 -exec dirname {} \;)
BUILD_JS_TARGETS := build-js
DEPLOY_JS_TARGETS := $(foreach m,$(JS_MODULES),deploy-js/$(m))

build-js:
	@echo "Building js"
	npm install && npm run build

deploy-js/%: build-js
	@echo "Deploying [$*] to $(NAMESPACE)"
ifeq ($(ENVIRONMENT),review)
	$(call prepare_review_app,$*)
endif
	$(call pull_images_for_cache,$*)
	cd $* && skaffold run --profile=$(ENVIRONMENT)
	$(call verify_deployment_status,$*)
	$(call tag_n_push,$*)

deploy-js: $(DEPLOY_JS_TARGETS)

##
## JAVA modules
##

JAVA_MODULES := $(shell find apps services -name build.gradle -mindepth 2 -maxdepth 2 -exec dirname {} \;)
BUILD_JAVA_TARGET := build-java
DEPLOY_JAVA_TARGETS := $(foreach m,$(JAVA_MODULES),deploy-java/$(m))

build-java:
	@echo "Building java"
	./gradlew build -Penv=$(ENVIRONMENT)

deploy-java/%: build-java
	@echo "Deploying [$*] to $(NAMESPACE)"
ifeq ($(ENVIRONMENT),review)
	$(call prepare_review_app,$*)
endif
	$(call pull_images_for_cache,$*)
	cd $* && skaffold run --profile=$(ENVIRONMENT)
	$(call verify_deployment_status,$*)
	$(call tag_n_push,$*)

deploy-java: $(DEPLOY_JAVA_TARGETS)

##
## Get `cacheFrom` values from skafold and pull corresponding images
## Input params:
## $(1) - path to skaffold.yaml
## $(2) - optional profile in skaffold.yaml
##
define pull_images_for_cache
	$(eval IMAGE_NAMES := `(\
	  yq r $(1)/skaffold.yaml -j | jq -re '.profiles[]? | select(.name=="$(ENVIRONMENT)") | .build.artifacts[]?.docker.cacheFrom | .[]?' \
	  || \
	  yq r $(1)/skaffold.yaml -j | jq -re '.build.artifacts[]?.docker.cacheFrom | .[]?' \
	) | sort -u`)
	for img in $(IMAGE_NAMES); do\
		docker pull $$img || true;\
    done
endef

##
## Get the newest image id by name from skaffold.yaml, tag it with "latest" and push it
## Input params:
## $(1) - path to skaffold.yaml
##
define tag_n_push
	$(eval IMAGE_NAMES := `(\
	  yq r $(1)/skaffold.yaml -j | jq -re '.profiles[]? | select(.name=="$(ENVIRONMENT)") | .build.artifacts[]?.imageName' \
	  || \
	  yq r $(1)/skaffold.yaml -j | jq -re '.build.artifacts[]?.imageName' \
	) | sort -u`)
	for img in $(IMAGE_NAMES); do\
		docker tag $$(docker images -q $$img | head -n 1) $$img:$(ENVIRONMENT);\
		docker push $$img:$(ENVIRONMENT);\
	done
endef

##
## Generate k8s manifest in build dir replacing the namespace
## Input params:
## $(1) - path to skaffold.yaml
##
define prepare_review_app
	mkdir -p $(1)/build; \
	kustomize build $(1)/deploy/review \
	| sed 's/\(namespace: \).*/\1$(NAMESPACE)/g' \
	| tr '\n' '\f' \
	| sed "s/\(.*kind: Namespace$$(printf '\f')metadata:$$(printf '\f')  name: \)[[:print:]]*\(.*\)/\1$(NAMESPACE)\2/g" \
	| tr '\f' '\n' \
	> $(1)/build/review-app.yaml
endef

##
## Get rollout status of deployments
## Input params:
## $(1) - path to module
##
define verify_deployment_status
	$(eval DEPLOYMENTS := `(yq r -j $(1)/skaffold.yaml | jq -re '.profiles[]? | select(.name=="dev") | .deploy.kustomize.kustomizePath | select(.!=null)' \
	  || \
	  yq r -j $(1)/skaffold.yaml | jq -re '.deploy.kustomize.kustomizePath | select(.!=null)' \
	  || \
	  deploy/review) | \
	  (echo -n $(1)/ && cat) | \
	  xargs kustomize build | \
	  yq r -d* -j - | \
	  jq -re '.[] | select(.kind=="Deployment") | .metadata.name'`)
	for app in $(DEPLOYMENTS); do\
        kubectl rollout status deploy $$app -n$(NAMESPACE);\
    done
endef
