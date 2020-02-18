#!/bin/bash

kubectl config set-cluster poseidon --certificate-authority=ca.pem --embed-certs=true --server=https://192.168.1.211:6443
kubectl config set-credentials admin --client-certificate=admin.pem --client-key=admin-key.pem
kubectl config set-context poseidon --cluster=poseidon --user=admin
kubectl config use-context poseidon
