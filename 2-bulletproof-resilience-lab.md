Here’s an improved version of your markdown document with better structure, consistent formatting, and enhanced readability:  

---

# **Lab: CockroachDB Bulletproof Resilience**  

## **Introduction**  

In this hands-on technical lab, you'll explore the resilience and fault-tolerant capabilities of **CockroachDB**, a modern distributed SQL database designed for mission-critical applications. CockroachDB is renowned for its ability to handle unexpected failures gracefully while ensuring data integrity and availability.  

### **Lab Objectives**  
In this lab, you will:  
1. **Simulate node failures**: Test CockroachDB's fault tolerance by intentionally taking down nodes and observing how the system maintains high availability and data consistency.  
2. **Explore data replication and recovery**: Understand CockroachDB's replication strategy and observe how data is automatically redistributed and recovered across the cluster.  
3. **Perform real-time failover testing**: Witness CockroachDB's seamless failover process, ensuring uninterrupted service for applications and end-users.  

By the end of this lab, you will have a deeper understanding of CockroachDB's architecture and its ability to provide bulletproof resilience in distributed environments.  

Let’s get started and put CockroachDB’s resilience to the test!  

---

## **Step 1: Set Environment Variables**  

Define the three regions where CockroachDB is running:  

```bash
export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1"  
```  

---

## **Step 2: Tail Bank Client Logs**  

Tail the logs from one of the bank-client pods to monitor system behavior during the lab:  

1. **List the available pods in Region 2:**  
   ```bash
export POD_NAME=$(kubectl get pods -n $region_2-roach-bank -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "bank-client" | head -n 1)
  
   ```  

2. **Grab the pod name and tail the logs:**  
   ```bash
   kubectl logs -f --tail 10 $POD_NAME -n $region_2-roach-bank  
   ```  

---

## **Step 3: Open a New Terminal and Set Variables**  

Set environment variables again in a new terminal window for additional actions:  

```bash
export region_1="eu-west-1"  
export region_2="europe-west4"  
export region_3="uksouth"  
```  

---

## **Step 4: Simulate Node Failures**  

### **Action 1: Delete a Node (Pod)**  

Delete a single node (pod) from a region to simulate a failure:  

- **From Region 1:**  
  ```bash
  kubectl delete po cockroachdb-0 -n $region_1  
  ```

Run the command below to check the node status via the `cockroach node status` command. 

  ```bash
cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
```

What do you observe?
**Example Output**
```

```

As this lab is running in Kubernetes CockroachDB will self heal deploying a new node (pod) to replace the failed node. The cluster will return to a healthy state and `ranges_underreplicated` will return to zero.

```bash
cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
```  

What do you observe?
**Example Output**
```
```

Now lets repeat the process in another region 

- **From Region 3:**  
  ```bash
  kubectl delete po cockroachdb-0 -n $region_3  
  ```  

Again the cluster returns to a healthy state and `ranges_underreplicated` will return to zero. This all happens without impacting the workload running in the unaffected region.

```bash
cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
```  

What do you observe?
**Example Output**
```
```

### **Action 2: Scale the StatefulSet to Zero**  

Scale down the StatefulSet in Region 1 to simulate an entire region's nodes going offline:  

```bash
kubectl scale statefulsets cockroachdb --replicas=0 -n $region_1  
```  

### **Action 3: Scale the StatefulSet Back to Two Nodes**  

Scale the StatefulSet back up in Region 1 to restore nodes:  

```bash
kubectl scale statefulsets cockroachdb --replicas=2 -n $region_1  
```  

---

## **Conclusion**  

In this lab, you explored CockroachDB’s fault tolerance and resilience by:  
- Simulating node failures and observing how CockroachDB maintains high availability and consistency.  
- Monitoring the automatic redistribution and recovery of data across the cluster.  
- Scaling nodes down and back up to test CockroachDB’s ability to recover from regional failures.  

This hands-on exercise demonstrated CockroachDB’s robust architecture, including its ability to handle hardware failures, network interruptions, and other challenges without compromising service continuity or data integrity.  

By completing this lab, you gained valuable insights into how distributed systems like CockroachDB ensure bulletproof resilience for modern, mission-critical applications.