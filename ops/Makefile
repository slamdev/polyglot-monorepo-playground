.PHONY: clean
clean:
	@echo "ops-clean $(ENVIRONMENT)"

.PHONY: check
check:
	$(call validate_minifest,namespace-configuration)
	$(call validate_minifest,registry-ui/k8s)

.PHONY: build
build:
	@echo "ops-build $(ENVIRONMENT)"

.PHONY: deploy
deploy:
	cd namespace-configuration && skaffold run --verbosity=info
	cd registry-ui && skaffold run --verbosity=info
	$(call rollout_statuses,$(PROJECT)-ops)
