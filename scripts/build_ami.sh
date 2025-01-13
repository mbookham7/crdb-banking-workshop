# Install k3d and kubectl on to your server
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install cockroach binary
wget https://binaries.cockroachdb.com/cockroach-latest.linux-amd64.tgz
tar -xvzf cockroach-latest.linux-amd64.tgz
sudo cp cockroach-*/cockroach /usr/local/bin/
echo $(cockroach version)

# Create a cluster named `banking-workshop` with just a single server node:
k3d cluster create banking-workshop --api-port 6550 -p 30000-30400:30000-30400@server:0

# Use the new cluster with kubectl, e.g.:
echo $(kubectl get nodes)

# Create three variables with the region names desired.
export region_1="eu-west-1"
export region_2="us-east-1"
export region_3="eu-north-1"

# Create three separate namespaces.
kubectl create namespace $region_1
kubectl create namespace $region_2 
kubectl create namespace $region_3

# We are going to create the certificates required to deploy CockroachDB.
mkdir certs my-safe-directory

# Create the certificate authority.
cockroach cert create-ca \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key

# Create the client certificate.
cockroach cert create-client \
root \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key

# Add these certificates as kubernetes secrets into each of the namespaces.
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

# Create the node certificates for each region.
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

# Add it as a secret in to the first namespace.

kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_1

rm certs/node.crt
rm certs/node.key

# Now do the same again for the second region.

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

# Create the secret in the second region.

kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_2

rm certs/node.crt
rm certs/node.key

# Now the finally the third region.

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

# Upload the secret.

kubectl create secret \
generic cockroachdb.node \
--from-file=certs \
--namespace $region_3

rm certs/node.crt
rm certs/node.key

# Deploy the three separate StatefulSet.
# > There are some hard codes region names in these files. If you have changed the region names you will need to edit these files. You may also want to adjust the replica count and resource requests and limits depending on your computer spec.

kubectl apply -f ../manifest/region_1-cockroachdb-statefulset-secure.yaml -n $region_1
kubectl apply -f ../manifest/region_2-cockroachdb-statefulset-secure.yaml -n $region_2
kubectl apply -f ../manifest/region_3-cockroachdb-statefulset-secure.yaml -n $region_3

# Once the pods are deployed we need to initialize the cluster. This is done by 'execing' into the container and running the `cockroach init` command.

sleep 30s

kubectl exec \
--namespace $region_1 \
-it cockroachdb-0 \
-- /cockroach/cockroach init \
--certs-dir=/cockroach/cockroach-certs

# Check that all the pods have started successfully.

echo $(kubectl get pods --namespace $region_1)
echo $(kubectl get pods --namespace $region_2)
echo $(kubectl get pods --namespace $region_3)

# Next, create a secure client in the first region.
kubectl create -f ../manifest/client-secure.yaml --namespace $region_1

# Create a SQL User and Roach Bank Database

sleep 30s

kubectl exec -it cockroachdb-client-secure -n $region_1 -- ./cockroach sql -f https://raw.githubusercontent.com/mbookham7/crdb-banking-workshop/refs/heads/master/scripts/create_user_and_database.sql --certs-dir=/cockroach-certs --host=cockroachdb-public

# Create namespaces for Roach Bank
kubectl create namespace $region_1-roach-bank
kubectl create namespace $region_2-roach-bank
kubectl create namespace $region_3-roach-bank

# Deploy Roach Bank Server component
kubectl apply -f ../manifest/region_1-deployment.yaml -n $region_1-roach-bank
kubectl apply -f ../manifest/region_2-deployment.yaml -n $region_2-roach-bank
kubectl apply -f ../manifest/region_3-deployment.yaml -n $region_3-roach-bank

# Check the Roach Bank Server pods are running
echo $(kubectl get po -n $region_1-roach-bank)
echo $(kubectl get po -n $region_2-roach-bank)
echo $(kubectl get po -n $region_3-roach-bank)

# Apply Roach Bank Client configmap
kubectl apply -f ../manifest/bank-client-config.yaml -n $region_1-roach-bank
kubectl apply -f ../manifest/bank-client-config.yaml -n $region_2-roach-bank
kubectl apply -f ../manifest/bank-client-config.yaml -n $region_3-roach-bank

# Deploy Roach Bank Client
kubectl apply -f ../manifest/bank-client-deploy.yaml -n $region_1-roach-bank
kubectl apply -f ../manifest/bank-client-deploy.yaml -n $region_2-roach-bank
kubectl apply -f ../manifest/bank-client-deploy.yaml -n $region_3-roach-bank

# Check the Roach Bank Server pods are running
echo $(kubectl get po -n $region_1-roach-bank)
echo $(kubectl get po -n $region_2-roach-bank)
echo $(kubectl get po -n $region_3-roach-bank)


echo $(kubectl get svc -A)