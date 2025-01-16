# Setup Enviroment

```
git clone https://github.com/mbookham7/crdb-banking-workshop.git
cd crdb-banking-workshop
```
```
cd scripts
chmod a+x build_ami.sh install_docker.sh
./install_docker.sh
./build_ami.sh
```

# Add Docker's official GPG key:
```
sudo apt-get update
sudo apt-get install ca-certificates curl -y
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
k3d cluster create banking-workshop --api-port 6550 -p 30000-30400:30000-30400@server:0
```

Use the new cluster with kubectl, e.g.:
```
kubectl get nodes
```

## Deploy CockroachDB into the the k3d cluster

Create three variables with the region names desired.
```
export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"
```

Create three separate namespaces.
```
kubectl create namespace $region_1
kubectl create namespace $region_2 
kubectl create namespace $region_3
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
--namespace $region_1

kubectl create secret \
generic cockroachdb.client.root \
--from-file=certs \
--namespace $region_2

kubectl create secret \
generic cockroachdb.client.root \
--from-file=certs \
--namespace $region_3
```

Create the node certificates for each region.
```
cockroach cert create-node \
localhost 127.0.0.1 \
cockroachdb-public \
cockroachdb-public.$region_1 \
cockroachdb-public.$region_1.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$region_1" \
"*.cockroachdb.$region_1.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```
Add it as a secret in to the first namespace.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_1
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
cockroachdb-public.$region_2 \
cockroachdb-public.$region_2.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$region_2" \
"*.cockroachdb.$region_2.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Create the secret in the second region.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_2
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
cockroachdb-public.$region_3 \
cockroachdb-public.$region_3.svc.cluster.local \
"*.cockroachdb" \
"*.cockroachdb.$region_3" \
"*.cockroachdb.$region_3.svc.cluster.local" \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key
```

Upload the secret.
```
kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_3
```

```
rm certs/node.crt
rm certs/node.key
```

Deploy the three separate StatefulSet.
> There are some hard codes region names in these files. If you have changed the region names you will need to edit these files. You may also want to adjust the replica count and resource requests and limits depending on your computer spec.
```
kubectl apply -f manifest/region_1-cockroachdb-statefulset-secure.yaml -n $region_1
kubectl apply -f manifest/region_2-cockroachdb-statefulset-secure.yaml -n $region_2
kubectl apply -f manifest/region_3-cockroachdb-statefulset-secure.yaml -n $region_3
```

Once the pods are deployed we need to initialize the cluster. This is done by 'execing' into the container and running the `cockroach init` command.
```
kubectl exec \
--namespace $region_1 \
-it cockroachdb-0 \
-- /cockroach/cockroach init \
--certs-dir=/cockroach/cockroach-certs
```

Check that all the pods have started successfully.
```
kubectl get pods --namespace $region_1
kubectl get pods --namespace $region_2
kubectl get pods --namespace $region_3
```

Next, create a secure client in the first region.
```
kubectl create -f manifest/client-secure.yaml --namespace $region_1
```

```
kubectl exec -it cockroachdb-client-secure -n $region_1 -- ./cockroach sql --certs-dir=/cockroach-certs --host=cockroachdb-public
```

```
CREATE USER craig WITH PASSWORD 'cockroach';
GRANT admin TO craig;
CREATE database roach_bank;
USE roach_bank;
\q
```

```
kubectl create namespace $region_1-roach-bank
kubectl create namespace $region_2-roach-bank
kubectl create namespace $region_3-roach-bank
```

```
kubectl apply -f ./manifest/region_1-deployment.yaml -n $region_1-roach-bank
kubectl apply -f ./manifest/region_2-deployment.yaml -n $region_2-roach-bank
kubectl apply -f ./manifest/region_3-deployment.yaml -n $region_3-roach-bank
```

```
kubectl get po -n $region_1-roach-bank
kubectl get po -n $region_2-roach-bank
kubectl get po -n $region_3-roach-bank
```

```
kubectl apply -f ./manifest/bank-client-config.yaml -n $region_1-roach-bank
kubectl apply -f ./manifest/bank-client-config.yaml -n $region_2-roach-bank
kubectl apply -f ./manifest/bank-client-config.yaml -n $region_3-roach-bank
```

```
kubectl apply -f manifest/bank-client-deploy.yaml -n $region_1-roach-bank
kubectl apply -f manifest/bank-client-deploy.yaml -n $region_2-roach-bank
kubectl apply -f manifest/bank-client-deploy.yaml -n $region_3-roach-bank
```

```
kubectl get svc -A
```



## Clean Up
To clean up the resources delete the cluster and delete the certificates.
```
k3d cluster delete kube-doom
rm -R certs my-safe-directory
```