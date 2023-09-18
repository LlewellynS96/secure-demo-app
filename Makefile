CLUSTER_NAME=secure-demo-app

.PHONY: all k3d metallb istio clena

all: k3d metallb istio
	@echo Done

k3d:
	k3d cluster create $(CLUSTER_NAME) --k3s-arg "--disable=traefik@server:*" --k3s-arg "--disable=servicelb@server:*" --no-lb -p "30000-30100:30000-30100@server:0:direct"

metallb: k3d
	helm upgrade --install -n metallb-system --create-namespace metallb ./metallb -f ./metallb/values.yaml --wait
	$(eval IP_ADDRESS=$(shell docker inspect   -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-$(CLUSTER_NAME)-server-0 | cut -d "." -f1-3))
	sed -e 's|0.0.0.0\/0|$(IP_ADDRESS).253\/32|g' manifests/metallb.yaml | kubectl apply -f -

istio: k3d metallb
	helm upgrade --install -n istio-system --create-namespace istio-base ./istio/base -f ./istio/base/values.yaml --wait
	helm upgrade --install -n istio-system istiod ./istio/istiod -f ./istio/istiod/values.yaml --wait
	helm upgrade --install gateway -n istio-ingress ./istio/gateway --create-namespace -f ./istio/gateway/values.yaml --wait


clean:
	k3d cluster delete $(CLUSTER_NAME)
