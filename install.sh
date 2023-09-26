CLUSTER_NAME=secure-demo-app
NETWORK_NAME=$CLUSTER_NAME-network
LOCAL_REGISTRY_PORT=12345
NEW_CLUSTER=false
UNINSTALL=false
CREATE_REGISTRY=false
EXTERNAL_LB=false
ISTIO=false
DISABLE_LB=""
INSTALL_MONITORING=false
INSTALL_BOOKINFO=false
BUILD_GRPC=false

while getopts ":nc:urlimbg" option; do
   case $option in
      n) NEW_CLUSTER=true
         ;;
      c) CLUSTER_NAME=$OPTARG
         ;;
      u) UNINSTALL=true
         ;;
      r) CREATE_REGISTRY=true
         ;;
      l) EXTERNAL_LB=true
         ;;
      i) ISTIO=true
         ;;
      m) INSTALL_MONITORING=true
         ;;
      b) INSTALL_BOOKINFO=true
         ;;
      g) BUILD_GRPC=true
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if $UNINSTALL ; then
  docker stop "local-registry"
  docker rm "local-registry"
  k3d cluster delete $CLUSTER_NAME
  docker network rm $NETWORK_NAME
fi

if [ -z "$(docker network ls | grep $NETWORK_NAME)" ]; then
  docker network create $NETWORK_NAME
fi


if $EXTERNAL_LB ; then
  DISABLE_LB='--k3s-arg --disable=servicelb@server:*'
fi

USE_REGISTRY=""

if $CREATE_REGISTRY ; then
  docker run -d -p 0.0.0.0:12345:5000 --name "local-registry" registry:2
  docker network connect "$NETWORK_NAME" "local-registry"
  USE_REGISTRY="--registry-config registries.yaml"
fi

if $NEW_CLUSTER ; then
  k3d cluster create $CLUSTER_NAME --network $NETWORK_NAME --k3s-arg "--disable=traefik@server:*" $DISABLE_LB $USE_REGISTRY --no-lb -p "30000-30099:30000-30099@server:0:direct"
fi

if $EXTERNAL_LB ; then
  helm upgrade --install -n metallb-system --create-namespace metallb ./metallb -f ./metallb/values.yaml --wait
  IP_ADDRESS=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-$CLUSTER_NAME-server-0 | cut -d "." -f1-3)
  sed -e 's|0.0.0.0\/0|'"$IP_ADDRESS"'.253\/32|g' manifests/metallb.yaml | kubectl apply -f -
fi

if $ISTIO ; then
  helm upgrade --install -n istio-system --create-namespace istio-base ./istio/base -f ./istio/base/values.yaml --wait
  helm upgrade --install -n istio-system istiod ./istio/istiod -f ./istio/istiod/values.yaml --wait
  helm upgrade --install gateway -n istio-ingress ./istio/gateway --create-namespace -f ./istio/gateway/values.yaml --wait
  kubectl apply -f ./manifests/istio-gateway.yaml
fi

if $INSTALL_MONITORING ; then
  kubectl apply -f ./manifests/prometheus.yaml
  kubectl apply -f ./manifests/kiali.yaml
fi

if $BUILD_GRPC ; then
  docker build -t cache apps/protobuf
  CLIENT_IMAGE_TAG=$(awk -F'"' '/appVersion/{print $2}' apps/client/helm/Chart.yaml)
  docker build -t localhost:$LOCAL_REGISTRY_PORT/client:$CLIENT_IMAGE_TAG apps/client
  docker push localhost:$LOCAL_REGISTRY_PORT/client:$CLIENT_IMAGE_TAG
  SERVER_IMAGE_TAG=$(awk -F'"' '/appVersion/{print $2}' apps/server/helm/Chart.yaml)
  docker build -t localhost:$LOCAL_REGISTRY_PORT/server:$SERVER_IMAGE_TAG apps/server
  docker push localhost:$LOCAL_REGISTRY_PORT/server:$SERVER_IMAGE_TAG
  helm upgrade --install client apps/client/helm
  helm upgrade --install server apps/server/helm
fi

if $INSTALL_BOOKINFO ; then
  kubectl apply -f ./manifests/bookinfo.yaml
fi

