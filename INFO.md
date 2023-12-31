<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.55.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible"></a> [ansible](#module\_ansible) | ./ansible | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/compute | n/a |
| <a name="module_control_plane"></a> [control\_plane](#module\_control\_plane) | ./modules/compute | n/a |
| <a name="module_cos"></a> [cos](#module\_cos) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cos | v6.10.0 |
| <a name="module_microk8s_subnet"></a> [microk8s\_subnet](#module\_microk8s\_subnet) | terraform-ibm-modules/vpc/ibm//modules/subnet | 1.1.1 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.6 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-ibm-modules/vpc/ibm//modules/security-group | 1.1.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-ibm-modules/vpc/ibm//modules/vpc | 1.1.1 |
| <a name="module_worker_bucket"></a> [worker\_bucket](#module\_worker\_bucket) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cos | v6.10.0 |
| <a name="module_worker_node"></a> [worker\_node](#module\_worker\_node) | ./modules/compute | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_flowlogs](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_floating_ip.bastion](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_floating_ip) | resource |
| [ibm_is_flow_log.control_plane](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_flow_log) | resource |
| [ibm_is_flow_log.worker_nodes](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_flow_log) | resource |
| [ibm_is_ssh_key.generated_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_ssh_key) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [ibm_is_ssh_key.sshkey](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/is_ssh_key) | data source |
| [ibm_is_zones.regional](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/is_zones) | data source |
| [ibm_resource_group.resource_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_classic_access"></a> [classic\_access](#input\_classic\_access) | Allow classic access to the VPC. | `bool` | `false` | no |
| <a name="input_controller_node_count"></a> [controller\_node\_count](#input\_controller\_node\_count) | Number of microk8s controller nodes to create. | `number` | `1` | no |
| <a name="input_default_address_prefix"></a> [default\_address\_prefix](#input\_default\_address\_prefix) | The address prefix to use for the VPC. Default is set to auto. | `string` | `"auto"` | no |
| <a name="input_existing_cos_instance"></a> [existing\_cos\_instance](#input\_existing\_cos\_instance) | Name of an existing Object Storage instance to use for the VPC Flowlog collectors. If not set, a new Object Storage instance will be created. | `string` | `""` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Name of an existing Resource Group to use for resources. If not set, a new Resource Group will be created. | `string` | `""` | no |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | Name of an existing SSH key to use for the VPC. If not set, a new SSH key will be created. | `string` | `""` | no |
| <a name="input_frontend_rules"></a> [frontend\_rules](#input\_frontend\_rules) | A list of security group rules to be added to the microk8s security group | <pre>list(<br>    object({<br>      name      = string<br>      direction = string<br>      remote    = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-http",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 80,<br>      "port_min": 80<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-https",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 443,<br>      "port_min": 443<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-ssh",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 22,<br>      "port_min": 22<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-cluster-join",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 25000,<br>      "port_min": 25000<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "icmp": {<br>      "code": 0,<br>      "type": 8<br>    },<br>    "ip_version": "ipv4",<br>    "name": "inbound-icmp",<br>    "remote": "0.0.0.0/0"<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "microk8s-api-inbound",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 16443,<br>      "port_min": 16443<br>    }<br>  },<br>  {<br>    "direction": "outbound",<br>    "ip_version": "ipv4",<br>    "name": "services-outbound",<br>    "remote": "161.26.0.0/16"<br>  },<br>  {<br>    "direction": "outbound",<br>    "ip_version": "ipv4",<br>    "name": "all-outbound",<br>    "remote": "0.0.0.0/0"<br>  }<br>]</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API key needed to deploy the resources | `string` | n/a | yes |
| <a name="input_number_of_addresses"></a> [number\_of\_addresses](#input\_number\_of\_addresses) | Number of IPs to assign for each subnet. | `number` | `128` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner declaration for resource tags. e.g. 'ryantiffany' | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where resources will be deployed | `string` | n/a | yes |
| <a name="input_worker_node_count"></a> [worker\_node\_count](#input\_worker\_node\_count) | Number of microk8s worker nodes to create. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_ip"></a> [bastion\_ip](#output\_bastion\_ip) | Bastion Public IP |
| <a name="output_step_01_ping_hosts"></a> [step\_01\_ping\_hosts](#output\_step\_01\_ping\_hosts) | Run the following playbook to ping all hosts and check connectivity |
| <a name="output_step_02_update_hosts"></a> [step\_02\_update\_hosts](#output\_step\_02\_update\_hosts) | Run the following playbook to update systems and install obersevability tools |
| <a name="output_step_03_deploy_cluster"></a> [step\_03\_deploy\_cluster](#output\_step\_03\_deploy\_cluster) | Run the following playbook to create the microk8s cluster |
<!-- END_TF_DOCS --><!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.55.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible"></a> [ansible](#module\_ansible) | ./ansible | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/compute | n/a |
| <a name="module_control_plane"></a> [control\_plane](#module\_control\_plane) | ./modules/compute | n/a |
| <a name="module_cos"></a> [cos](#module\_cos) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cos | v6.10.0 |
| <a name="module_microk8s_subnet"></a> [microk8s\_subnet](#module\_microk8s\_subnet) | terraform-ibm-modules/vpc/ibm//modules/subnet | 1.1.1 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.6 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-ibm-modules/vpc/ibm//modules/security-group | 1.1.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-ibm-modules/vpc/ibm//modules/vpc | 1.1.1 |
| <a name="module_worker_bucket"></a> [worker\_bucket](#module\_worker\_bucket) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cos | v6.10.0 |
| <a name="module_worker_node"></a> [worker\_node](#module\_worker\_node) | ./modules/compute | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_flowlogs](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_floating_ip.bastion](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_floating_ip) | resource |
| [ibm_is_flow_log.control_plane](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_flow_log) | resource |
| [ibm_is_flow_log.worker_nodes](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_flow_log) | resource |
| [ibm_is_ssh_key.generated_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/resources/is_ssh_key) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [ibm_is_ssh_key.sshkey](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/is_ssh_key) | data source |
| [ibm_is_zones.regional](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/is_zones) | data source |
| [ibm_resource_group.resource_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.55.0/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_classic_access"></a> [classic\_access](#input\_classic\_access) | Allow classic access to the VPC. | `bool` | `false` | no |
| <a name="input_controller_node_count"></a> [controller\_node\_count](#input\_controller\_node\_count) | Number of microk8s controller nodes to create. | `number` | `1` | no |
| <a name="input_default_address_prefix"></a> [default\_address\_prefix](#input\_default\_address\_prefix) | The address prefix to use for the VPC. Default is set to auto. | `string` | `"auto"` | no |
| <a name="input_existing_cos_instance"></a> [existing\_cos\_instance](#input\_existing\_cos\_instance) | Name of an existing Object Storage instance to use for the VPC Flowlog collectors. If not set, a new Object Storage instance will be created. | `string` | `""` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Name of an existing Resource Group to use for resources. If not set, a new Resource Group will be created. | `string` | `""` | no |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | Name of an existing SSH key to use for the VPC. If not set, a new SSH key will be created. | `string` | `""` | no |
| <a name="input_frontend_rules"></a> [frontend\_rules](#input\_frontend\_rules) | A list of security group rules to be added to the microk8s security group | <pre>list(<br>    object({<br>      name      = string<br>      direction = string<br>      remote    = string<br>      tcp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      udp = optional(<br>        object({<br>          port_max = optional(number)<br>          port_min = optional(number)<br>        })<br>      )<br>      icmp = optional(<br>        object({<br>          type = optional(number)<br>          code = optional(number)<br>        })<br>      )<br>    })<br>  )</pre> | <pre>[<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-http",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 80,<br>      "port_min": 80<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-https",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 443,<br>      "port_min": 443<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-ssh",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 22,<br>      "port_min": 22<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "inbound-cluster-join",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 25000,<br>      "port_min": 25000<br>    }<br>  },<br>  {<br>    "direction": "inbound",<br>    "icmp": {<br>      "code": 0,<br>      "type": 8<br>    },<br>    "ip_version": "ipv4",<br>    "name": "inbound-icmp",<br>    "remote": "0.0.0.0/0"<br>  },<br>  {<br>    "direction": "inbound",<br>    "ip_version": "ipv4",<br>    "name": "microk8s-api-inbound",<br>    "remote": "0.0.0.0/0",<br>    "tcp": {<br>      "port_max": 16443,<br>      "port_min": 16443<br>    }<br>  },<br>  {<br>    "direction": "outbound",<br>    "ip_version": "ipv4",<br>    "name": "services-outbound",<br>    "remote": "161.26.0.0/16"<br>  },<br>  {<br>    "direction": "outbound",<br>    "ip_version": "ipv4",<br>    "name": "all-outbound",<br>    "remote": "0.0.0.0/0"<br>  }<br>]</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud API key needed to deploy the resources | `string` | n/a | yes |
| <a name="input_number_of_addresses"></a> [number\_of\_addresses](#input\_number\_of\_addresses) | Number of IPs to assign for each subnet. | `number` | `128` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner declaration for resource tags. e.g. 'ryantiffany' | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where resources will be deployed | `string` | n/a | yes |
| <a name="input_worker_node_count"></a> [worker\_node\_count](#input\_worker\_node\_count) | Number of microk8s worker nodes to create. | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_ip"></a> [bastion\_ip](#output\_bastion\_ip) | Bastion Public IP |
| <a name="output_step_01_ping_hosts"></a> [step\_01\_ping\_hosts](#output\_step\_01\_ping\_hosts) | Run the following playbook to ping all hosts and check connectivity |
| <a name="output_step_02_update_hosts"></a> [step\_02\_update\_hosts](#output\_step\_02\_update\_hosts) | Run the following playbook to update systems and install obersevability tools |
| <a name="output_step_03_deploy_cluster"></a> [step\_03\_deploy\_cluster](#output\_step\_03\_deploy\_cluster) | Run the following playbook to create the microk8s cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
