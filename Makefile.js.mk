.PHONY: clean
clean: install
	cd apps/app1 && yarn run clean
	cd services/svc-js && yarn run clean

.PHONY: install
install:
	cd apps/app1 && yarn install
	cd services/svc-js && yarn install

.PHONY: check
check: install
	cd apps/app1 && yarn run test
	cd services/svc-js && yarn run test

.PHONY: build
build:
	cd apps/app1 && yarn run build
	cd services/svc-js && yarn run build

.PHONY: deploy
deploy:
	cd apps/app1 && docker build -f deploy/docker/Dockerfile .
	cd services/svc-js && docker build -f deploy/docker/Dockerfile .
