# Introduction to the CockroachDB Bulletproof Resilience Lab

In this hands-on technical lab, you'll explore the resilience and fault-tolerant capabilities of **CockroachDB**, a modern distributed SQL database designed for mission-critical applications. CockroachDB is renowned for its ability to handle unexpected failures gracefully while ensuring data integrity and availability. This lab is tailored to help you experience these features firsthand in a controlled environment.

In this lab, you will:

1. **Simulate node failures**: Test CockroachDB's fault tolerance by intentionally taking down nodes and observing how the system maintains high availability and data consistency.
2. **Explore data replication and recovery**: Dive into the mechanics of CockroachDB's replication strategy and understand how data is automatically redistributed and recovered across the cluster.
3. **Perform real-time failover testing**: Experience CockroachDB's seamless failover process, ensuring uninterrupted service for applications and end-users.

By the end of this lab, you will have gained a deeper understanding of CockroachDB's architecture and its ability to provide bulletproof resilience in distributed environments. This hands-on experience will showcase how CockroachDB keeps your applications running smoothly, even in the face of hardware failures, network interruptions, or other unexpected challenges.

Let’s get started and put CockroachDB’s resilience to the test!


```
export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"
```

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
