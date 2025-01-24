# **CockroachDB Banking Workshop**  

This repository provides a hands-on technical workshop for engineers and architects in the banking sector to explore CockroachDB. The workshop demonstrates how to leverage CockroachDB’s distributed SQL database for:  

- Scalability across global deployments.  
- Fault tolerance and resilience in mission-critical applications.  
- Data placement strategies to meet compliance and performance requirements.  

---

## **Repository Overview**  

### **Directories**  
- **`manifests/`**: Contains Kubernetes manifests and configuration files for setting up the workshop environment.  
- **`scripts/`**: Includes scripts to automate setup, installation, and key tasks for lab exercises.  

---

## **Workshop Labs**  

### **Lab 1: Setup Lab Environment**  
[**View Lab Guide**](labs/0-setup-lab-environment.md)  
This lab guides you through setting up the workshop environment. You’ll clone the repository, install prerequisites, and configure CockroachDB to run in Kubernetes.  

---

### **Lab 2: Built for Scale**  
[**View Lab Guide**](labs/1-built-for-scale-lab.md)  
In this lab, you’ll explore CockroachDB’s scalability features. Learn how the database automatically handles distributed workloads and scales horizontally across nodes.  

---

### **Lab 3: Bulletproof Resilience**  
[**View Lab Guide**](labs/2-bulletproof-resilience-lab.md)  
This lab focuses on CockroachDB’s fault tolerance. You’ll simulate node failures, monitor data recovery, and observe how CockroachDB ensures availability and consistency during disruptions.  

---

## **How to Use This Repository**  

1. Clone the repository:  
   ```bash
   git clone https://github.com/mbookham7/crdb-banking-workshop.git  
   cd crdb-banking-workshop  
   ```  

2. Follow the **Lab 1: Setup Lab Environment** guide to prepare your environment.  

3. Work through each subsequent lab to explore CockroachDB’s features.  

By completing this workshop, you’ll gain hands-on experience with CockroachDB’s unique capabilities for handling the demands of modern banking applications.  

--- 

Let me know if there are any specific details you'd like to add or adjust!