.PHONY: clean
clean: ;

.PHONY: check
check:
	$(call validate_minifest,namespace-configuration)
	$(call validate_minifest,registry-ui/k8s)
	$(call validate_minifest,gitlab-runner/overlays/c1)
	$(call validate_minifest,gitlab-runner/overlays/c10)
	$(call validate_minifest,postgres-backupper)

.PHONY: build
build: ;

.PHONY: deploy
deploy: ENVIRONMENT = ops
deploy: NAMESPACE = $(PROJECT)-$(ENVIRONMENT)
deploy:
	cd namespace-configuration && skaffold deploy --verbosity=info
	cd registry-ui && skaffold run --verbosity=info
	cd gitlab-runner && skaffold deploy --verbosity=info --profile=c1
	cd gitlab-runner && skaffold deploy --verbosity=info --profile=c10
	cd postgres-backupper && skaffold deploy --verbosity=info
	$(call rollout_statuses)
