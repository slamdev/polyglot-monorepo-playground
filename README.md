# polyglot-monorepo-playground

Showcase project that combines multiple services implemented in different languages and their deploy process.

[Makefile](https://www.gnu.org/software/make/manual/make.html) is used to orchestrate build and deploy processes.

Makefile has a global **deploy** target and targets to build\deploy separate parts of the project.

**Environment** concept is used in the whole process. Generally project has **dev** and **prod** environments.

The **e** flag is used to run build\deploy process for specific environment, e.g.:
```bash
make deploy e=prod
```

If the passed **environment** flag differs from **dev** or **prod**, the build system assumes that this is a **review** 
environment and the concept of [Review Apps](https://about.gitlab.com/features/review-apps/) is applied: 
the **review-[env]** namespace will be created and applications will be deployed there.

The **deploy** target uses [kustimize](https://github.com/kubernetes-sigs/kustomize) and 
[skaffold](https://github.com/GoogleContainerTools/skaffold) tools to manage k8s manifests.

## CI

Project uses a [Gitlab CI]() as an example but **.gitlab-ci.yml** can be easily converted to the manifest of any other 
CI system that supports running jobs in docker images.

## Modules

Project consists of multiple modules that have there own targets for build\deploy.

### ETC module

Different tools that should be build in first step since they are required for building process of other modules. 
In this specific project there are multiple docker images that are built and used in other modules.

Makefile command: `make deploy-etc`

### OPS module

Services that are used globally for all environments, like monitoring, logging, alerting. 
They live in single separate **ops** namespace.

Makefile command: `make deploy-ops`

### INFRA module

All that is not related to apps\services should be placed here. E.g. databases, queues, caches.
These tools are deployed to **dev**\\**prod** environments and to review apps.

Makefile command: `make deploy-infra e=dev`

### Services modules

These are the services that actually produce some business logic of the application. 
The are deployed to **dev**\\**prod** environments and to review apps.

#### JAVA

Java based services use [Gradle](https://gradle.org) tool to manage build process.

Makefile commands:
- `make build-java e=dev`
- `make deploy-java e=dev`

#### JS

JavaScript based services use [Lerna](https://github.com/lerna/lerna) tool to manage build process.

Makefile commands:
- `make build-js e=dev`
- `make deploy-js e=dev`
