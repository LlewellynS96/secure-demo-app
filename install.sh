#!/bin/bash

CLUSTER_NAME=secure-demo-app
NEW_CLUSTER=false
UNINSTALL=false
EXTERNAL_LB=false
ISTIO=false
DISABLE_LB=""
INSTALL_MONITORING=false
INSTALL_BOOKINFO=false

while getopts ":nc:ulimb" option; do
   case $option in
      n) NEW_CLUSTER=true
         ;;
      c) CLUSTER_NAME=$OPTARG
         ;;
      u) UNINSTALL=true
         ;;
      l) EXTERNAL_LB=true
         ;;
      i) ISTIO=true
         ;;
      m) INSTALL_MONITORING=true
         ;;
      b) INSTALL_BOOKINFO=true
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if $UNINSTALL ; then
   k3d cluster delete $CLUSTER_NAME
fi

if $EXTERNAL_LB ; then
   DISABLE_LB='--k3s-arg --disable=servicelb@server:*'
fi

if $NEW_CLUSTER ; then
  k3d cluster create $CLUSTER_NAME --k3s-arg "--disable=traefik@server:*" $DISABLE_LB --no-lb -p "30000-30099:30000-30099@server:0:direct"
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

if $INSTALL_BOOKINFO ; then
  kubectl apply -f ./manifests/bookinfo.yaml
fi

