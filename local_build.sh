#!/bin/bash

TAG=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 7 | head -n 1`

podman build -t 127.0.0.1:5000/host-inventory:$TAG -f Dockerfile

podman push 127.0.0.1:5000/host-inventory:$TAG `minikube ip`:5000/host-inventory:$TAG --tls-verify=false

bonfire local get --set-image-tag host-inventory=$TAG -a host-inventory | oc apply -f -

echo $TAG
