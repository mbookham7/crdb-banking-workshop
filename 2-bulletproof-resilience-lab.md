# Demo 1 Cockroach Resilience under load


export eks_region="eu-west-1"
export gke_region="europe-west4"
export aks_region="uksouth"

Tail the logs from one of the bank-client pods.
```
kubectl get po -n $gke_region-roach-bank
```

Grab the pod name and tail the logs.
```
kubectl logs -f --tail 10 $bank-client-pod $gke_region-roach-bank
```

Open a new terminal window and set the variables.
```
export eks_region="eu-west-1"
export gke_region="europe-west4"
export aks_region="uksouth"
```

Delete a single node or pod in k8s terms form any region.
```
kubectl delete po cockroachdb-0 -n $eks_region
```

Delete a single node or pod in k8s terms form any region.
```
kubectl delete po cockroachdb-0 -n $aks_region
```

Scale StatefulSet to zero
```
kubectl scale statefulsets cockroachdb --replicas=0 -n $eks_region
```

Scale back to three nodes.
```
kubectl scale statefulsets cockroachdb --replicas=3 -n $eks_region
```
