# Setup Enviroment

```
git clone https://github.com/mbookham7/crdb-banking-workshop.git
cd crdb-banking-workshop
```
```
cd scripts
chmod a+x build_ami.sh install_docker.sh
./install_docker.sh
```

```
./build_ami.sh
```


## Clean Up
To clean up the resources delete the cluster and delete the certificates.
```
k3d cluster delete kube-doom
rm -R certs my-safe-directory
```