export eks_region="eu-west-1"
export gke_region="europe-west4"
export aks_region="uksouth"


Check the pods are running.
```
kubectl get po -n $eks_region
kubectl get po -n $gke_region
kubectl get po -n $aks_region
```

Increase the number of replicas for each of the StatefulSet in each of the regions.
```
kubectl scale statefulsets cockroachdb --replicas=2 -n $eks_region
kubectl scale statefulsets cockroachdb --replicas=2 -n $gke_region
kubectl scale statefulsets cockroachdb --replicas=2 -n $aks_region
```

Get the statefulSet from each region.
```
kubectl get statefulsets cockroachdb -n $eks_region
kubectl get statefulsets cockroachdb -n $gke_region
kubectl get statefulsets cockroachdb -n $aks_region
```