.PHONY: clean
clean: ;

.PHONY: check
check: ;

.PHONY: build
build: ;

.PHONY: deploy
deploy:
	cd builder-images/base && docker build -t slamdev/playground-builder-base .
	docker push slamdev/playground-builder-base
	cd builder-images/java && docker build -t slamdev/playground-builder-java .
	docker push slamdev/playground-builder-java
	cd builder-images/js && docker build -t slamdev/playground-builder-js .
	docker push slamdev/playground-builder-js
