# **Lab 2 - CockroachDB Bulletproof Resilience**

## **Introduction to the Roach Bank Resilience Lab**   

In this hands-on lab, you'll explore the resilience and fault-tolerance capabilities of **CockroachDB**, a modern distributed SQL database designed for mission-critical applications. CockroachDB is engineered to handle unexpected failures gracefully while ensuring data integrity and availability.  

### **Objectives**  

By completing this lab, you will:  

1. **Simulate node failures:** Test CockroachDB's ability to maintain high availability and data consistency during node failures.  
2. **Explore data replication and recovery:** Learn how CockroachDB redistributes and recovers data across the cluster automatically.  
3. **Perform real-time failover testing:** Observe CockroachDB’s seamless failover process to ensure uninterrupted service for end-users.  

This lab demonstrates CockroachDB’s robust architecture and its capacity to withstand hardware failures, network disruptions, and other challenges without compromising performance or availability.  

Let’s dive in and test the resilience of CockroachDB!  

---

## **Step 1: Set Environment Variables**  

Define the regions where CockroachDB is running by setting the environment variables:  

```bash
export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1"  
```  

Navigate to the `scripts` directory:

```bash
cd crdb-banking-workshop/scripts
```

---

## **Step 2: Monitor Bank Client Logs**  

To observe CockroachDB’s behavior during failure simulations, follow these steps:  

1. **Retrieve a bank-client pod name in Region 2:**  
   ```bash
   export POD_NAME=$(kubectl get pods -n $region_2-roach-bank -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep "bank-client" | head -n 1)
   ```  

2. **Tail the logs of the bank-client pod:**  
   ```bash
   kubectl logs -f --tail 10 $POD_NAME -n $region_2-roach-bank  
   ```  

---

## **Step 3: Simulate Node Failures (New Terminal)**  

🚨 **Open a new terminal window before starting Step 3**. Set the same environment variables in the new terminal:  

```bash
export region_1="eu-west-1"  
export region_2="us-east-1"  
export region_3="eu-north-1"  
``` 



### **Action 1: Delete a Node (Pod)**  

1. Simulate a node failure by deleting a pod in **Region 1**:  
   ```bash
   kubectl delete po cockroachdb-0 -n $region_1  
   ```  

2. Check the cluster status using:  
   ```bash
   cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
   ```  

   **Example Output:**  
   ```  
   id |                           address                            | is_available | is_live | replicas_leaders | replicas_leaseholders | ranges | ranges_unavailable | ranges_underreplicated  
   ----+-------------------------------------------------------------+--------------+---------+------------------+-----------------------+--------+--------------------+-------------------------  
    1 | cockroachdb-0.cockroachdb.eu-west-1.svc.cluster.local:26257  | false        | false   |               10 |                    10 |     46 |                  0 |                      0  
    2 | cockroachdb-0.cockroachdb.us-east-1.svc.cluster.local:26257  | true         | true    |               11 |                    11 |     46 |                  0 |                     11  
   ```  

   Notice that `is_available` is marked as `false` for the deleted node and `ranges_underreplicated` has increased. CockroachDB will automatically replace the failed node (pod), and the cluster will return to a healthy state.  

3. Repeat the process in **Region 3**:  
   ```bash
   kubectl delete po cockroachdb-0 -n $region_3  
   ```  

4. Observe how the cluster self-heals by running:  
   ```bash
   cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
   ```  

---

### **Action 2: Scale Down the StatefulSet**  

1. Scale down the StatefulSet in **Region 1** to simulate a region-wide failure:  
   ```bash
   kubectl scale statefulsets cockroachdb --replicas=0 -n $region_1  
   ```  

2. Check the cluster status:  
   ```bash
   cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
   ```  

   Despite all nodes in Region 1 being offline, workloads in other regions remain unaffected, and the cluster continues to operate without downtime.  

---

### **Action 3: Scale the StatefulSet Back Up**  

1. Restore the nodes in **Region 1** by scaling the StatefulSet back to two nodes:  
   ```bash
   kubectl scale statefulsets cockroachdb --replicas=2 -n $region_1  
   ```  

2. Verify the cluster status:  
   ```bash
   cockroach node status --ranges --certs-dir=certs --host=localhost:30200  
   ```  

   The restored nodes rejoin the cluster and resume their roles in maintaining data replication and consistency.  

---

## **Conclusion**  

In this lab, you explored CockroachDB’s fault-tolerance capabilities by:  
- Simulating node and region failures.  
- Monitoring data redistribution and recovery.  
- Ensuring continuous operation despite hardware or network disruptions.  

This hands-on experience highlights CockroachDB’s robust architecture and its ability to provide seamless resilience for mission-critical applications.  

You now have practical insights into how distributed systems like CockroachDB handle real-world challenges, ensuring high availability, data integrity, and performance.  

**Congratulations on completing the lab!**