FROM alpine:3.8

RUN apk upgrade --no-cache \
# Install common tools
 && apk add --no-cache bash ca-certificates curl wget make \
# Install docker
 && apk add --no-cache docker \
# Install kubectl
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && mv kubectl /usr/local/bin/ \
 && chmod +x /usr/local/bin/kubectl \
# && kubectl config set-cluster
# Install kustomize
 && curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest |\
  grep browser_download |\
  grep linux |\
  cut -d '"' -f 4 |\
  xargs curl -O -L \
 && mv kustomize_*_linux_amd64 /usr/local/bin/kustomize \
 && chmod +x /usr/local/bin/kustomize \
 && kustomize version \
# Install skaffold
 && curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 \
 && mv skaffold /usr/local/bin/ \
 && chmod +x /usr/local/bin/skaffold \
 && skaffold version
