# Demo 1 Cockroach Resilience under load


export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"

Tail the logs from one of the bank-client pods.
```
kubectl get po -n $region_2-roach-bank
```

Grab the pod name and tail the logs.
```
kubectl logs -f --tail 10 $bank-client-pod-n $region_2-roach-bank
```

Open a new terminal window and set the variables.
```
export region_1="eu-west-1"
export region_2="europe-west4"
export region_3="uksouth"
```

Delete a single node or pod in k8s terms form any region.
```
kubectl delete po cockroachdb-0 -n $region_1
```

Delete a single node or pod in k8s terms form any region.
```
kubectl delete po cockroachdb-0 -n $region_3
```

Scale StatefulSet to zero
```
kubectl scale statefulsets cockroachdb --replicas=0 -n $region_1
```

Scale back to three nodes.
```
kubectl scale statefulsets cockroachdb --replicas=3 -n $region_1
```
