# 🚀 **Lab 3 - CockroachDB: Thrive Anywhere**

## 🧪 **Introduction: Roach Bank Data Placement Lab**

Welcome to the hands-on **Roach Bank Lab**! In this exercise, you'll explore how CockroachDB maintains high levels of performance in a multi-region setup—even in the face of latency challenges.

By simulating regional configurations and testing these, you'll gain insight into how CockroachDB handles:

* **Data placement**
* **Replication**

---

## 🎯 **Objectives**

By the end of this lab, you will:

1. ✅ **Create Global Tables** to test CockroachDB's ability to deliver lighting fast reads regardless of locality.
2. 🔄 **Explore data replication and placement**, observing how data is redistributed automatically.

This lab showcases CockroachDB’s data locality capabilities, cloud-native architecture—designed to **place data where it is needed** to enhance user experience.

---

## 🔧 **Step 1: Set Environment Variables**

Define your target regions using shell environment variables:

```bash
export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"
```

These regions will later be used when configuring multi-region support in your database.

---

## 🔌 **Step 2: Connect to the Cluster**

Use the `cockroach sql` client to connect to your running CockroachDB cluster:

```bash
cockroach sql --certs-dir=certs --host=localhost:30200
```

> ⚠️ Make sure your cluster is already running and `certs` directory is correctly configured.

---

## 🌍 **Step 3: Configure Multi-Region Support**

Convert the `roach_bank` database into a **multi-region database** by setting the primary and additional regions:

```sql
ALTER DATABASE roach_bank PRIMARY REGION "us-east-1";
ALTER DATABASE roach_bank ADD REGION "eu-north-1";
ALTER DATABASE roach_bank ADD REGION "eu-west-1";
```

### ✅ What this does:

* Sets `"us-east-1"` as the **primary region** for the database.
* Adds `"eu-north-1"` and `"eu-west-1"` as **secondary regions**.
* Enables CockroachDB to **automatically replicate and balance data** across these regions.

---

## 🌐 **Step 4: Create a GLOBAL Table**

A **GLOBAL table** is **replicated across all regions** in the cluster.

### ✅ Use case:

* Best for **reference data** (e.g., `currencies`, `countries`, `regions`) that is **read-heavy** and changes infrequently.

### 🔍 Characteristics:

* 🟢 **Fast reads** from any region
* 🔴 **Slower writes** due to global consensus requirement

#### ➕ Convert `region` table to a global table:

```sql
USE roach_bank;
ALTER TABLE region SET LOCALITY GLOBAL;
```

### 🧭 Optional: View placement of records

To verify data distribution after setting global locality:

```sql
SHOW RANGES FROM TABLE region;
```

As you can  see from the example output below there is now a replica on every node. Three voting replicas and two non voting replicas.

```sql
   start_key   |   end_key    | range_id |  replicas   |                                                                  replica_localities                                                                  | voting_replicas | non_voting_replicas | learner_replicas | split_enforced_until
---------------+--------------+----------+-------------+------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------+---------------------+------------------+-----------------------
  …/<TableMin> | …/<TableMax> |       89 | {1,2,3,5,6} | {"cloud=aws,region=eu-west-1","cloud=aws,region=us-east-1","cloud=aws,region=eu-north-1","cloud=aws,region=us-east-1","cloud=aws,region=eu-north-1"} | {2,3,5}         | {1,6}               | {}               | NULL
(1 row)
---
```

## 📌 **Step 5: Pin Data to Regional Locality (REGIONAL BY ROW)**

Now let’s make key user data tables **region-aware**, by pinning each row to a specific region based on the `city`.

This optimizes **latency** and **resilience** for region-specific data.

### 📘 Tables to be modified:

* `account`
* `transaction`
* `transaction_item`

---

### 🔁 Modify `account` table

1. **Add a computed column** `region` that determines row placement:

```sql
ALTER TABLE account ADD COLUMN region crdb_internal_region AS (
  CASE
    WHEN city IN ('stockholm','copenhagen','helsinki','oslo','riga','tallinn') THEN 'eu-north-1'
    WHEN city IN ('berlin','hamburg','munich','frankfurt','dusseldorf','leipzig','dortmund','essen','stuttgart','zurich','krakov','zagraeb','zaragoza','lodz','athens','bratislava','prague','sofia','bucharest','vienna','warsaw','budapest') THEN 'us-east-1'
    WHEN city IN ('dublin','belfast','liverpool','manchester','glasgow','birmingham','leeds','london','amsterdam','rotterdam','antwerp','hague','ghent','brussels','lyon','lisbon','toulouse','paris','cologne','seville','marseille','rome','milan','naples','turin','valencia','palermo','madrid','barcelona','sintra','lisbon') THEN 'eu-west-1'
    ELSE 'eu-north-1'
  END
) STORED NOT NULL;
```

2. **Set table locality to regional by row:**

```sql
ALTER TABLE account SET LOCALITY REGIONAL BY ROW AS region;
```

---

### 🔁 Repeat for `transaction` and `transaction_item` tables

Use the same logic as above, replacing the table name:

#### For `transaction`:

```sql
ALTER TABLE transaction ADD COLUMN region crdb_internal_region AS (
  ... same CASE statement ...
) STORED NOT NULL;

ALTER TABLE transaction SET LOCALITY REGIONAL BY ROW AS region;
```

#### For `transaction_item`:

```sql
ALTER TABLE transaction_item ADD COLUMN region crdb_internal_region AS (
  ... same CASE statement ...
) STORED NOT NULL;

ALTER TABLE transaction_item SET LOCALITY REGIONAL BY ROW AS region;
```

---

## 🧭 **Step 6: Verify Range Placement**

Use CockroachDB's introspection tools to inspect how data is distributed across the cluster.

### 🔍 Query placement metadata:

```sql
SELECT 
    range_id,
    start_key_pretty,
    replicas,
    lease_holder
FROM crdb_internal.ranges
WHERE table_name = 'account';
```

Or use the higher-level utility:

```sql
SHOW RANGES FROM TABLE account;
```

### 🧠 How to interpret:

* **Leaseholder**: Node responsible for serving reads and writes.
* **Replicas**: Nodes holding a copy of the range.
* **Start Key**: Shows partitioned ranges, indicating data separation by region.

---

## 💡 Bonus: Inspect Range by Value

You can also check how a specific region's data is placed:

```sql
SHOW RANGES FROM TABLE account FOR VALUES ('us-east-1');
```

This confirms that the rows tagged for `us-east-1` are stored in the appropriate regional ranges.

---

## ✅ **Wrap-Up & Key Takeaways**

In this lab, you:

* Configured a CockroachDB **multi-region cluster**
* Used **GLOBAL and REGIONAL BY ROW** locality settings
* Verified data placement using **internal inspection tools**
* Learned how CockroachDB handles **automatic failover, consistency, and high availability**

> 💬 **Explore further**: Try simulating a node failure and querying regional data to see how the cluster responds in real time!

[**Home**](/README.md)

