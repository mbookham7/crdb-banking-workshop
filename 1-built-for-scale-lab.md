export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"


Check the pods are running.
```
kubectl get po -n $region_1
kubectl get po -n $region_2
kubectl get po -n $region_3
```

Look at number of replicas per node

Look at the number of leaseholders per node.

Increase the number of replicas for each of the StatefulSet in each of the regions.
```
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_1
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_2
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_3
```

Get the statefulSet from each region.
```
kubectl get statefulsets cockroachdb -n $region_1
kubectl get statefulsets cockroachdb -n $region_2
kubectl get statefulsets cockroachdb -n $region_3
```