# **Setup Lab Environment**

This lab requires a prepared environment to work with **CockroachDB** and **Roach Bank**. Follow the steps below to set up all the necessary components.

---

## **Step 1: Clone the Lab Repository**

All the code for this lab is stored in a GitHub repository. Clone the repository and navigate to the directory containing the code:

```bash
git clone https://github.com/mbookham7/crdb-banking-workshop.git
cd crdb-banking-workshop
```

---

## **Step 2: Install Required Components**

CockroachDB and Roach Bank will run in Kubernetes, using **k3d** as the Kubernetes runtime. To install all the required components, follow these steps:

1. Navigate to the `scripts` directory:
   ```bash
   cd scripts
   ```

2. Make the shell scripts executable:
   ```bash
   chmod a+x build_ami.sh install_docker.sh
   ```

3. Run the `install_docker.sh` script to install Docker, as it is required for k3d:
   ```bash
   ./install_docker.sh
   ```

---

## **Step 3: Install Prerequisites and Deploy CockroachDB**

Once Docker is installed and running, run the `build_ami.sh` script to install the remaining prerequisites and deploy CockroachDB along with Roach Bank:

```bash
./build_ami.sh
```

---

## **Step 4: Verify Lab Environment**

The lab environment is now ready for use. Move on to the first lab to begin exploring **CockroachDB** and **Roach Bank**.

<div style="position: fixed; bottom: 10px; right: 10px; font-size: 14px; color: gray;">
  <a href="/markdown/1-built-for-scale-lab.md" style="text-decoration: none; color: black;">Go to Lab 1</a>
</div>

[**Home**](/README.md)