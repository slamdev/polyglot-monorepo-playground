.PHONY: clean
clean:
	cd services/svc-java && ./gradlew clean --console=plain --no-daemon

.PHONY: check
check:
	cd services/svc-java && ./gradlew check --console=plain --no-daemon

.PHONY: build
build:
	cd services/svc-java && ./gradlew assemble --console=plain --no-daemon

.PHONY: deploy
deploy:
	cd services/svc-java && skaffold run --verbosity=info --profile=$(ENVIRONMENT)
