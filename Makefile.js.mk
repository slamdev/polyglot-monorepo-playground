.PHONY: clean
clean: install
	cd apps/app1 && yarn run clean
	cd services/svc-js && yarn run clean

.PHONY: install
install:
	cd apps/app1 && yarn install
	cd services/svc-js && yarn install

.PHONY: check
check: install
	cd apps/app1 && yarn run test
	$(call validate_minifest,apps/app1/deploy/k8s/overlays/$(ENVIRONMENT))
	cd services/svc-js && yarn run test
	$(call validate_minifest,services/svc-js/deploy/k8s/overlays/$(ENVIRONMENT))

.PHONY: build
build:
	cd apps/app1 && yarn run build
	cd services/svc-js && yarn run build

.PHONY: deploy
deploy:
	cd apps/app1 && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call rollout_status,app1-app,$(PROJECT)-$(ENVIRONMENT))
	$(call tag_n_push,apps/app1,$(ENVIRONMENT))
	cd services/svc-js && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call rollout_status,svc-js-app,$(PROJECT)-$(ENVIRONMENT))
	$(call tag_n_push,services/svc-js,$(ENVIRONMENT))
