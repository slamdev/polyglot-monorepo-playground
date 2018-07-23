.PHONY: clean
clean:
	@echo "ops-clean $(ENVIRONMENT)"

.PHONY: check
check:
	@echo "ops-check $(ENVIRONMENT)"

.PHONY: build
build:
	@echo "ops-build $(ENVIRONMENT)"

.PHONY: deploy
deploy:
	cd namespace-configuration && skaffold run --verbosity=info
	cd registry-ui && skaffold run --verbosity=info
