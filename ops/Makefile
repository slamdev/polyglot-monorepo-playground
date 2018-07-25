.PHONY: clean
clean: ;

.PHONY: check
check:
	$(call validate_minifest,namespace-configuration)
	$(call validate_minifest,registry-ui/k8s)

.PHONY: build
build: ;

.PHONY: deploy
deploy: ENVIRONMENT = ops
deploy: NAMESPACE = $(PROJECT)-$(ENVIRONMENT)
deploy:
	cd namespace-configuration && skaffold run --verbosity=info
	cd registry-ui && skaffold run --verbosity=info
	$(call rollout_statuses)
	$(call tag_n_push,registry-ui,latest)
