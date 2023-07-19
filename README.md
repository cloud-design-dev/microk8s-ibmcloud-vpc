# microk8s-ibmcloud-vpc

Deploying a MicroK8s HA cluster on IBM Cloud VPC using Terraform and Ansible

![Diagram of deployment](https://dsc.cloud/quickshare/Shared-Image-2023-07-05-12-40-53.png)


## Local Pre-requisites


## Cloud Shell Pre-requisites

The default version of Terraform in Cloud Shell is failry out of date. You can use the [`tfswitch`]() command to install a newer version:


```bash
rtiffany@cloudshell:~/microk8s-ibmcloud-vpc$ terraform version 
Terraform v0.14.3
rtiffany@cloudshell:~/microk8s-ibmcloud-vpc$ tfswitch
2023/07/19 18:39:09 Creating directory for terraform: /home/rtiffany/.terraform.versions/
✔ 1.5.3
Downloading https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip to terraform_1.5.3_linux_amd64.zip
Downloading ...
20983262 bytes downloaded.
Switched terraform to version "1.5.3" 
rtiffany@cloudshell:~/microk8s-ibmcloud-vpc$ terraform version 
Terraform v1.5
```
