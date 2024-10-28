

# Add Docker's official GPG key:
```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

# Add the repository to Apt sources:

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER && newgrp docker
docker run hello-world
```

# Install k3d and kubectl on to your server
```
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# Install cockroach binary
```
wget https://binaries.cockroachdb.com/cockroach-latest.linux-amd64.tgz
tar -xvzf cockroach-latest.linux-amd64.tgz
sudo cp cockroach-*/cockroach /usr/local/bin/
cockroach version
```

Create a cluster named `banking-workshop` with just a single server node:
```
k3d cluster create banking-workshop --api-port 6550 -p "8090:8090@loadbalancer" --port '8080:8080@loadbalancer'
```

Use the new cluster with kubectl, e.g.:
```
kubectl get nodes
```

## Deploy CockroachDB into the the k3d cluster

```
git clone https://github.com/mbookham7/crdb-banking-workshop.git
cd crdb-banking-workshop
```


Create three variables with the region names desired.
```
export eks_region="eu-west-1"
export gke_region="europe-west4"
export aks_region="uksouth"
```

Create three separate namespaces.
```
kubectl create namespace $eks_region
kubectl create namespace $gke_region 
kubectl create namespace $aks_region
```

We are going to create the certificates required to deploy CockroachDB.
```
mkdir certs my-safe-directory
```

Create the certificate authority.
```
cockroach cert create-ca \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Create the client certificate.
```
cockroach cert create-client \
root \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Add these certificates as kubernetes secrets into each of the namespaces.
```
kubectl create secret \
generic cockroachdb.client.root \
--from-file=certs \
--namespace $eks_region

kubectl create secret \
generic cockroachdb.client.root \
--from-file=certs \
--namespace $gke_region

kubectl create secret \
generic cockroachdb.client.root \
--from-file=certs \
--namespace $aks_region
```

Create the node certificates for each region.
```
cockroach cert create-node \
localhost 127.0.0.1 \
cockroachdb-public \
cockroachdb-public.$eks_region \
cockroachdb-public.$eks_region.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$eks_region" \
"*.cockroachdb.$eks_region.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```
Add it as a secret in to the first namespace.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $eks_region
```

```
rm certs/node.crt
rm certs/node.key
```

Now do the same again for the second region.
```
cockroach cert create-node \
localhost 127.0.0.1 \
cockroachdb-public \
cockroachdb-public.$gke_region \
cockroachdb-public.$gke_region.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$gke_region" \
"*.cockroachdb.$gke_region.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Create the secret in the second region.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $gke_region
```

```
rm certs/node.crt
rm certs/node.key
```

Now the finally the third region.
```
cockroach cert create-node \
localhost 127.0.0.1 \
cockroachdb-public \
cockroachdb-public.$aks_region \
cockroachdb-public.$aks_region.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$aks_region" \
"*.cockroachdb.$aks_region.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Upload the secret.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $aks_region
```

```
rm certs/node.crt
rm certs/node.key
```

Deploy the three separate StatefulSet.
> There are some hard codes region names in these files. If you have changed the region names you will need to edit these files. You may also want to adjust the replica count and resource requests and limits depending on your computer spec.
```
kubectl apply -f manifest/aws-cockroachdb-statefulset-secure.yaml -n $eks_region
kubectl apply -f manifest/gke-cockroachdb-statefulset-secure.yaml -n $gke_region
kubectl apply -f manifest/azure-cockroachdb-statefulset-secure.yaml -n $aks_region
```

Once the pods are deployed we need to initialize the cluster. This is done by 'execing' into the container and running the `cockroach init` command.
```
kubectl exec \
--namespace $eks_region \
-it cockroachdb-0 \
-- /cockroach/cockroach init \
--certs-dir=/cockroach/cockroach-certs
```

Check that all the pods have started successfully.
```
kubectl get pods --namespace $eks_region
kubectl get pods --namespace $gke_region
kubectl get pods --namespace $aks_region
```

Next, create a secure client in the first region.
```
kubectl create -f manifest/client-secure.yaml --namespace $eks_region
```

```
kubectl exec -it cockroachdb-client-secure -n $eks_region -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

```
CREATE USER craig WITH PASSWORD 'cockroach';
GRANT admin TO craig;
CREATE database roach_bank;
USE roach_bank;
\q
```

export eks_region="eu-west-1"
export gke_region="europe-west4"
export aks_region="uksouth"


```
kubectl create namespace $eks_region-roach-bank
kubectl create namespace $gke_region-roach-bank
kubectl create namespace $aks_region-roach-bank
```

```
kubectl apply -f ./manifest/aws-deployment.yaml -n $eks_region-roach-bank
kubectl apply -f ./manifest/gke-deployment.yaml -n $gke_region-roach-bank
kubectl apply -f ./manifest/azure-deployment.yaml -n $aks_region-roach-bank
```

```
kubectl get po -n $eks_region-roach-bank
kubectl get po -n $gke_region-roach-bank
kubectl get po -n $aks_region-roach-bank
```

```
kubectl apply -f ./manifest/bank-client-config.yaml -n $eks_region-roach-bank
kubectl apply -f ./manifest/bank-client-config.yaml -n $gke_region-roach-bank
kubectl apply -f ./manifest/bank-client-config.yaml -n $aks_region-roach-bank
```

```
kubectl apply -f manifest/bank-client-deploy.yaml -n $eks_region-roach-bank
kubectl apply -f manifest/bank-client-deploy.yaml -n $gke_region-roach-bank
kubectl apply -f manifest/bank-client-deploy.yaml -n $aks_region-roach-bank
```

Ingress Roach Bank
```
kubectl apply -f manifest/crdb-ingress.yaml -n $eks_region-roach-bank
kubectl apply -f manifest/roach-bank-ingress.yaml -n $eks_region-roach-bank
```



## Clean Up
To clean up the resources delete the cluster and delete the certificates.
```
k3d cluster delete kube-doom
rm -R certs my-safe-directory
```

