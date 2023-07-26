# Deploy a microk8s cluster on IBM Cloud VPC :rocket:

In this guide we will deploy a testing [microk8s][microk8s-homepage] cluster in to an IBM Cloud VPC :cloud:. MicroK8s allows you to deploy fully functional, highly available Kubernetes clusters on a wide variety of infrastructure and platforms. With the ability to quickly toggle features on and off, microk8s is a great tool for testing and learning Kubernetes.

In this guide we will be using [Terraform][terraform-homepage] to provision the VPC infrastructure and [Ansible][ansible-homepage] to handle the post provisioning configuration of the the cluster.

![Microk8s on IBM Cloud VPC](https://dsc.cloud/quickshare/vpc-microk8s.png)

This guide is written to utilize [IBM Cloud Shell][cloud-shell] as the development environment. Cloud Shell is a free, browser-based shell environment that includes Terraform, Ansible, and the IBM Cloud CLI. If you prefer to use your own environment, see the [Local Prerequisites](#local-prerequisites) section below to ensure you have all the required software installed.

## Prerequisites

To deploy our microk8s cluster, you will need to ensure you have the following prerequisites:

- IBM Cloud API Key. See [here](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key) for instructions on how to create one via the Portal. Alternately you can use the following CLI command to create one:

    ```shell
    ibmcloud iam api-key-create "$(whoami)-microk8s-vpc-apikey" -d "API key for microk8s deployment" --file "$(whoami)-microk8s-vpc-apikey.json"
    ```

- Recent version of [Terraform][terraform-install] installed. This guide was tested on `terraform 1.5.3`.
- A recent version of [Ansible][ansible-install] installed. This guide was tested on `ansible 2.15.2`.
- `(Optional)` - [tfswitch][tfswitch-install] installed. The `tfswitch` utility allows you to run multiple versions of Terraform on the same system. If you do not have a particular version of terraform installed, tfswitch will download the version you select from an interactive menu.

## Deploying the cluster

With the prerequisites installed and up to date, you can start deploying the cluster.

1. Clone this repo and `cd` into the `microk8s-ibmcloud-vpc` directory.

    ```bash
    git clone https://github.com/cloud-design-dev/microk8s-ibmcloud-vpc.git
    cd microk8s-ibmcloud-vpc
    ```

1. Copy the `tfvars-example` to `terraform.tfvars` file and update the values as needed. See [here](./INFO.md) for full list of variables.:

    ```bash
    cp tfvars-example terraform.tfvars
    ```

1. Initialize Terraform:

    ```bash
    terraform init -upgrade
    ```

1. Run a Terraform plan:

    ```bash
    terraform plan -out "$(terraform workspace show).tfplan" 
    ```

1. Run Terraform apply:

    ```bash
    terraform apply "$(terraform workspace show).tfplan"
    ```

Once the cluster is deployed, you should see some output about your deployed infrastructure, as well as the commands for running the Ansible playbooks.

```text
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

bastion_ip = "<your bastion ip>"
step_01_ping_hosts = "ansible-playbook -i ansible/inventory.ini  ansible/playbooks/ping-all.yml"
step_02_update_hosts = "ansible-playbook -i ansible/inventory.ini ansible/playbooks/update-systems.yml"
step_03_deploy_cluster = "ansible-playbook -i ansible/inventory.ini ansible/playbooks/configure-microk8s.yml"
```

***

## Run Ansible playbooks

1. Run the `ping-all.yml` playbook to ensure all hosts are reachable:

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/ping-all.yml
    ```

1. Run the `update-systems.yml` playbook to update the hosts and insure required packages are installed:

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/update-systems.yml
    ```

1. Finally, run the `configure-microk8s.yml` playbook to configure our microk8s cluster:

    ```bash
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/configure-microk8s.yml
    ```

When the `configure-microk8s.yml` playbook completes, you can run the following command to get the clusters compute nodes:

```bash
ansible -m shell -b -a "microk8s kubectl get nodes" CONTROL_PLANE_NODE -i ansible/inventory.ini 
```

If everything went as planned you should see output similar to the following:

```text
[$] <git:(main*)> ansible -m shell -b -a "microk8s kubectl get nodes" qywx-controller-1 -i ansible/inventory.ini
qywx-controller-1 | CHANGED | rc=0 >>
NAME                STATUS   ROLES       AGE    VERSION
qywx-worker-1       Ready    worker      7m5s   v1.27.2
qywx-worker-3       Ready    worker      7m4s   v1.27.2
qywx-worker-2       Ready    worker      7m3s   v1.27.2
qywx-controller-1   Ready    contoller   11m    v1.27.2
```

[cloud-shell]: [https://cloud.ibm.com/shel](https://cloud.ibm.com/docs/cloud-shell?topic=cloud-shell-getting-started)l
[terraform-homepage]: https://www.terraform.io/
[ansible-homepage]: https://www.ansible.com/
[microk8s-homepage]: https://microk8s.io/
[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible
[terraform-install]: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
[tfswitch-install]: https://tfswitch.warrensbox.com/
