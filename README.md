# skaffold-monorepo-playground

Issues to resolve:

- Skaffold is not tagging images with `latest` and `prod`. Workaround could be adding a separate step after 
`skaffold run`, that will parse output from `docker images --format "{{.ID}}: {{.CreatedAt}} {{.Digest}}" IMAGE_NAME`,
get newest image ID, tag it with `latest` or `prod` and push it

- No way to implement review apps since `namespace` is statically defined in `kustomization.yaml`. Workaround could be 
running kustomize before skaffold, store output in `build` directory, replace `namespace` field via `sed` and run
skaffold with this output
