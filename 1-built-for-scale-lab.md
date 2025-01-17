# Lab 1 - Built for Scale

Here’s a possible draft for your technical lab introduction:  

---

**Introduction to the Roach Bank Scaling Lab**  

Welcome to the **Roach Bank Scaling Lab**, where you’ll gain hands-on experience with **CockroachDB**, a resilient, scalable, and distributed SQL database. In this lab, you’ll work with **Roach Bank**, a demo banking application built to showcase CockroachDB's ability to handle real-world scenarios.  

Your mission: **scale CockroachDB to accommodate increasing application load.**  

As Roach Bank grows, its infrastructure must adapt to ensure high availability, low latency, and seamless customer experience. In this lab, you’ll learn how to:  
- Deploy additional CockroachDB nodes to support increased traffic.  
- Observe the impact of scaling on performance and resilience.  
- Use CockroachDB’s features to ensure the application remains consistent and fault-tolerant under load.  

By the end of the session, you’ll have a deeper understanding of CockroachDB’s capabilities and how distributed systems can meet the demands of modern applications.  

Let’s get started on scaling Roach Bank to new heights!

First, three environment variables are added for the tree regions CockroachDB is currently running in. In this Lab `eu-west-1`,`us-east-1`,`eu-north-1`.

```
export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"
```

Currently CockroachDB is running three nodes one in each region. With the set of commands below we can see the current nodes running inside Kubernetes.

```
kubectl get po -n $region_1
kubectl get po -n $region_2
kubectl get po -n $region_3
```

Before the number of nodes are increased lets take a look at the placement of replicas and leaseholders. First 

```
cockroach node status --ranges --certs-dir=certs --host=localhost:30200
```

Look at number of replicas (ranges) per node, and leaseholders (replicas_leaseholders)
```
 | replicas_leaders | replicas_leaseholders | ranges | ranges_unavailable | ranges_underreplicated
+------------------+-----------------------+--------+--------------------+-------------------------
|               19 |                    19 |     56 |                  0 |                      0
|               20 |                    20 |     56 |                  0 |                      0
|               17 |                    17 |     56 |                  0 |                      0
```

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

```
cockroach node status --ranges --certs-dir=certs --host=localhost:30200
```

```
| replicas_leaders | replicas_leaseholders | ranges | ranges_unavailable | ranges_underreplicated
+------------------+-----------------------+--------+--------------------+-------------------------
|               10 |                    10 |     46 |                  0 |                      0
|               10 |                    10 |     46 |                  0 |                      0
|                9 |                     9 |     45 |                  0 |                      0   
|                8 |                     8 |     45 |                  0 |                      0
|                8 |                     8 |     46 |                  0 |                      0
|               11 |                    11 |     46 |                  0 |                      0