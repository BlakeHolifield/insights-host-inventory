#!/bin/bash

TAG=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 7 | head -n 1`
IMAGE="127.0.0.1:5000/host-inventory"

podman build -t $IMAGE:$TAG -f Dockerfile

podman push $IMAGE:$TAG `minikube ip`:5000/host-inventory:$TAG --tls-verify=false

bonfire deploy --namespace metaverse --get-dependencies -p host-inventory/host-inventory/IMAGE_TAG=$TAG host-inventory -i $IMAGE=$TAG

echo $TAG
