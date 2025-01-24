# **Lab 1 - CockroachDB Built for Scale**  

## **Introduction to the Roach Bank Scaling Lab**  

Welcome to the **Roach Bank Scaling Lab**, where you’ll gain hands-on experience with **CockroachDB**, a resilient, scalable, and distributed SQL database. In this lab, you’ll work with **Roach Bank**, a demo banking application built to showcase CockroachDB's ability to handle real-world scenarios.  

### **Objective**  
Your mission: **scale CockroachDB to accommodate increasing application load.**  

As Roach Bank grows, its infrastructure must adapt to ensure:  
- High availability  
- Low latency  
- Seamless customer experience  

### **What You’ll Learn**  
In this lab, you’ll:  
1. Deploy additional CockroachDB nodes to support increased traffic.  
2. Observe the impact of scaling on performance and resilience.  
3. Use CockroachDB features to maintain consistency and fault tolerance under load.  

By the end of this session, you’ll have a deeper understanding of CockroachDB’s capabilities and how distributed systems can meet the demands of modern applications.  

---

## **Step 1: Set Up Environment Variables**  

Define the three regions where CockroachDB is currently running:  

```bash
export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1"  
```  

---

## **Step 2: View Current Nodes**  

CockroachDB is currently running three nodes, one in each region. Use the following commands to check the nodes running inside Kubernetes:  

```bash
kubectl get po -n $region_1  
kubectl get po -n $region_2  
kubectl get po -n $region_3  
```  

---

## **Step 3: Examine Replica and Leaseholder Placement**  

Before scaling, review the placement of replicas and leaseholders. Run the following command to view the current state:  

```bash
cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
```  

### **Example Output**  
The output will display details such as the number of replicas and leaseholders per node:  

```
 | replicas_leaders | replicas_leaseholders | ranges | ranges_unavailable | ranges_underreplicated  
+------------------+-----------------------+--------+--------------------+-------------------------  
|               19 |                    19 |     56 |                  0 |                      0  
|               20 |                    20 |     56 |                  0 |                      0  
|               17 |                    17 |     56 |                  0 |                      0  
```  

---

## **Step 4: Scale the CockroachDB Cluster**  

Increase the number of CockroachDB nodes by scaling the StatefulSet. Add one new node to each region using the following commands:  

```bash
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_1  
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_2  
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_3  
```  

Wait for the new nodes to become `Ready` before proceeding. Use these commands to check the status:  

```bash
kubectl get statefulsets cockroachdb -n $region_1  
kubectl get statefulsets cockroachdb -n $region_2  
kubectl get statefulsets cockroachdb -n $region_3  
```  

---

## **Step 5: Observe Rebalancing**  

As new nodes join the cluster, replicas and leaseholders will automatically rebalance across the nodes. Monitor the rebalancing process using the following command:  

```bash
cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
```  

### **Key Observations**  
Run this command multiple times and observe how:  
- New nodes start to take some of the workload from existing nodes.  
- Replicas and leaseholders are evenly distributed across all nodes.  

### **Example Output**  
Here’s an example of the updated output:  

```
 | replicas_leaders | replicas_leaseholders | ranges | ranges_unavailable | ranges_underreplicated  
+------------------+-----------------------+--------+--------------------+-------------------------  
|               10 |                    10 |     46 |                  0 |                      0  
|               10 |                    10 |     46 |                  0 |                      0  
|                9 |                     9 |     45 |                  0 |                      0  
|                8 |                     8 |     45 |                  0 |                      0  
|                8 |                     8 |     46 |                  0 |                      0  
|               11 |                    11 |     46 |                  0 |                      0  
```  

---

## **Conclusion**  

In this lab, you gained hands-on experience with scaling a distributed database system, specifically CockroachDB, in a multi-region environment. You learned how to:  
- Configure environment variables for managing CockroachDB nodes across different regions.  
- Examine the current cluster state, including replica and leaseholder distribution.  
- Scale the CockroachDB cluster by adding nodes to each region and observe the system’s automatic rebalancing of replicas and leaseholders.  

These activities demonstrated CockroachDB’s ability to dynamically redistribute workload across nodes, ensuring efficient resource utilization and high availability. The rebalancing process highlighted the database’s fault tolerance and scalability features, critical for modern applications that demand resilience and low latency under fluctuating loads.  

By completing this lab, you have developed a deeper understanding of CockroachDB’s distributed architecture and how it simplifies scaling while maintaining consistency and reliability in real-world scenarios.

<div style="position: fixed; bottom: 10px; right: 10px; font-size: 14px; color: gray;">
  <a href="/markdown/2-bulletproof-resilience-lab.md" style="text-decoration: none; color: black;">Go to Lab 2</a>
</div>

[**Home**](/README.md)