FROM alpine

RUN apk upgrade --no-cache \
# Install common tools
 && apk add --no-cache bash curl wget make ca-certificates tar jq \
# Install yq (it's not in apk packages)
 && curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | \
  jq -re '.assets[] | select(.name=="yq_linux_amd64") | .browser_download_url' | \
  xargs curl -O -L \
 && mv yq_* /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq \
 && yq -V \
# Install docker
 && [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf \
 && curl -fL -o docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-`curl -s https://api.github.com/repos/docker/docker-ce/releases/latest | jq -re .name`.tgz" \
 && tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin/ \
 && rm docker.tgz \
# Install kubectl
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && mv kubectl /usr/local/bin/ \
 && chmod +x /usr/local/bin/kubectl \
 && kubectl config set-cluster example-cluster --server=https://example:443 --insecure-skip-tls-verify=true \
 && kubectl config set-credentials example-kube --username=kube --password=example \
 && kubectl config set-context example-system --cluster=example-cluster --user=example-kube \
 && kubectl config use-context example-system \
# Install kustomize
 && curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest |\
  jq -re '.assets[] | select(.name|test("kustomize_.*_linux_amd64")) | .browser_download_url' | \
  xargs curl -O -L \
 && mv kustomize_*_linux_amd64 /usr/local/bin/kustomize \
 && chmod +x /usr/local/bin/kustomize \
 && kustomize version \
# Install skaffold
 && curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 \
 && mv skaffold /usr/local/bin/ \
 && chmod +x /usr/local/bin/skaffold \
 && skaffold version
