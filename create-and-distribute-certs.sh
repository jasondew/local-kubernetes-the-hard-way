#!/bin/bash

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "system:masters",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

for instance in node1 node2 node3; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "system:nodes",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

INTERNAL_IP=$(dig +short ${instance}.local)

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=${instance},${instance}.local,${INTERNAL_IP} -profile=kubernetes ${instance}-csr.json | cfssljson -bare ${instance}
done

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "system:node-proxier",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "Kubernetes",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local,10.32.0.1,192.168.1.211,192.168.1.212,192.186.1.213 \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes


cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Pamplico",
      "O": "Kubernetes",
      "OU": "Kubernetes",
      "ST": "South Carolina"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account


for instance in node1 node2 node3; do
  scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

for instance in control1 control2 control3; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem ${instance}:~/
done
