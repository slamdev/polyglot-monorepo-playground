.PHONY: check
check:
	cd services/svc-java && ./gradlew check --console=plain --no-daemon

.PHONY: build
build:
	cd services/svc-java && ./gradlew assemble --console=plain --no-daemon

.PHONY: deploy
deploy:
	cd services/svc-java && docker build -f deploy/docker/Dockerfile .
