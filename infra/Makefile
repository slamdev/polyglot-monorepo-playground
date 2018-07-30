.PHONY: clean
clean:
	rm -rf namespace-configuration/build
	rm -rf rabbitmq/build
	rm -rf postgres/build

.PHONY: check
check:
	$(call validate_minifest,namespace-configuration/overlays/$(ENVIRONMENT))
	$(call validate_minifest,rabbitmq/k8s/overlays/$(ENVIRONMENT))
	$(call validate_minifest,postgres/k8s/overlays/$(ENVIRONMENT))

.PHONY: build
build: ;

.PHONY: deploy
deploy:
	$(call prepare_review_app_if_needed,namespace-configuration,overlays/$(ENVIRONMENT))
	cd namespace-configuration && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call prepare_review_app_if_needed,rabbitmq,k8s/overlays/$(ENVIRONMENT))
	cd rabbitmq && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call prepare_review_app_if_needed,postgres,k8s/overlays/$(ENVIRONMENT))
	cd postgres && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
