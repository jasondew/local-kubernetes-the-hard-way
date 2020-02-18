# Setup notes

Following Kubernetes: The Hard Way found at https://github.com/kelseyhightower/kubernetes-the-hard-way

Naming this cluster "poseidon"

## Control Plane

- control1 (192.168.1.211)
- control2 (192.168.1.212)
- control3 (192.168.1.213)

## Workers

- node1 (192.168.1.201)
- node2 (192.168.1.202)
- node3 (192.168.1.203)


## Discrepancies/TODOs

- don't have a load-balancer in front of the API servers
  - maybe run haproxy?
  - may need to rerun steps https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md#kubernetes-public-ip-address
- going with the name "poseidon" for the cluster (may need to update the certs?) (seems fine?)
- not sure about the cluster-cidr and service-cluster-ip-range settings (so i deleted them) (seems fine?)
- had to change --address to --bind-address
