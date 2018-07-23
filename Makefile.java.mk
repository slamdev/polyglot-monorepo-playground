.PHONY: clean
clean:
	cd services/svc-java && ./gradlew clean --console=plain --no-daemon

.PHONY: check
check:
	cd services/svc-java && ./gradlew check --console=plain --no-daemon
	$(call validate_minifest,services/svc-java/deploy/k8s/overlays/$(ENVIRONMENT))

.PHONY: build
build:
	cd services/svc-java && ./gradlew assemble --console=plain --no-daemon

.PHONY: deploy
deploy:
	cd services/svc-java && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
	$(call rollout_status,svc-java-app,$(PROJECT)-$(ENVIRONMENT))
