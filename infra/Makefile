.PHONY: clean
clean:
	@echo "infra-clean $(ENVIRONMENT)"

.PHONY: check
check:
	$(call validate_minifest,namespace-configuration/overlays/$(ENVIRONMENT))
	$(call validate_minifest,rabbitmq/k8s/overlays/$(ENVIRONMENT))

.PHONY: build
build:
	@echo "infra-build $(ENVIRONMENT)"

.PHONY: deploy
deploy:
	cd namespace-configuration && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	cd rabbitmq && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call tag_n_push,rabbitmq,$(ENVIRONMENT))
