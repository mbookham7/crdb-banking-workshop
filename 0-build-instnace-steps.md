# Setup Lab Environment  

All of the code for this lab is stored in a github repository. Using the commands below clone the repo and change directory into the folder containing the code.

```
git clone https://github.com/mbookham7/crdb-banking-workshop.git
cd crdb-banking-workshop
```

To install all the required components we need to run a couple of shell scripts. CockroachDB and Roach Bank will be running in Kubernetes. To do this change into the scripts directory, then make the two shell scripts executable and run the first script. This script installs Docker as k3d is the Kubernetes install that will be used.

```
cd scripts
chmod a+x build_ami.sh install_docker.sh
./install_docker.sh
```
Now that Docker is installed and working the remaining prerequisites can be installed and CockroachDB along with Roach Bank, our application.

```
./build_ami.sh
```
The lab environment should now be ready for the first lab.