CLUSTER_NAME=secure-demo-app

.PHONY: all k3d istio bookinfo kiali clean

all: clean k3d istio bookinfo kiali

k3d:
	k3d cluster create $(CLUSTER_NAME) --k3s-arg "--disable=traefik@server:*" --no-lb -p "30000-30099:30000-30099@server:0:direct"

istio:
	helm upgrade --install -n istio-system --create-namespace istio-base ./istio/base -f ./istio/base/values.yaml --wait
	helm upgrade --install -n istio-system istiod ./istio/istiod -f ./istio/istiod/values.yaml --wait
	helm upgrade --install gateway -n istio-ingress ./istio/gateway --create-namespace -f ./istio/gateway/values.yaml --wait

bookinfo:
	kubectl apply -f ./manifests/bookinfo.yaml

kiali:
	kubectl apply -f ./manifests/prometheus.yaml
	kubectl apply -f ./manifests/kiali.yaml

clean:
	k3d cluster delete $(CLUSTER_NAME)
