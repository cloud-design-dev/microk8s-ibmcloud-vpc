# Generate a random string for the prefix
resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# Generate a new SSH key for cloud shell ansible connection
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add a new SSH key to the region for cloud shell ansible connection
resource "ibm_is_ssh_key" "generated_key" {
  name           = "${local.prefix}-${var.region}-key"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = local.resource_group_id
  tags           = local.tags
}

# IF a resource group was not provided, create a new one
module "resource_group" {
  count               = var.existing_resource_group != "" ? 0 : 1
  source              = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.6"
  resource_group_name = "${local.prefix}-resource-group"
}

module "vpc" {
  source                      = "terraform-ibm-modules/vpc/ibm//modules/vpc"
  version                     = "1.1.1"
  create_vpc                  = true
  vpc_name                    = "${local.prefix}-vpc"
  resource_group_id           = local.resource_group_id
  classic_access              = var.classic_access
  default_address_prefix      = var.default_address_prefix
  default_network_acl_name    = "${local.prefix}-default-network-acl"
  default_security_group_name = "${local.prefix}-default-security-group"
  default_routing_table_name  = "${local.prefix}-default-routing-table"
  vpc_tags                    = local.tags
  locations                   = [local.vpc_zones[0].zone]
  number_of_addresses         = var.number_of_addresses
  create_gateway              = true
  subnet_name                 = "${local.prefix}-subnet"
  public_gateway_name         = "${local.prefix}-pub-gw"
  gateway_tags                = local.tags
}

module "security_group" {
  source                = "terraform-ibm-modules/vpc/ibm//modules/security-group"
  version               = "1.1.1"
  create_security_group = true
  name                  = "${local.prefix}-frontend-sg"
  vpc_id                = module.vpc.vpc_id[0]
  resource_group_id     = local.resource_group_id
  security_group_rules  = local.frontend_rules
}

module "microk8s_subnet" {
  source              = "terraform-ibm-modules/vpc/ibm//modules/subnet"
  version             = "1.1.1"
  name                = "${local.prefix}-microk8s-subnet"
  vpc_id              = module.vpc.vpc_id[0]
  resource_group_id   = local.resource_group_id
  location            = local.vpc_zones[0].zone
  number_of_addresses = var.number_of_addresses
  public_gateway      = module.vpc.public_gateway_ids[0]
}

module "bastion" {
  source            = "./modules/compute"
  prefix            = "${local.prefix}-bastion"
  resource_group_id = local.resource_group_id
  vpc_id            = module.vpc.vpc_id[0]
  subnet_id         = module.vpc.subnet_ids[0]
  security_group_id = module.security_group.security_group_id[0]
  zone              = local.vpc_zones[0].zone
  ssh_key_ids       = local.ssh_key_ids
  tags              = local.tags
}

resource "ibm_is_floating_ip" "bastion" {
  name           = "${local.prefix}-${local.vpc_zones[0].zone}-bastion-ip"
  target         = module.bastion.primary_network_interface
  resource_group = local.resource_group_id
  tags           = local.tags
}

module "control_plane" {
  count             = var.controller_node_count
  source            = "./modules/compute"
  prefix            = "${local.prefix}-controller-${count.index + 1}"
  resource_group_id = local.resource_group_id
  vpc_id            = module.vpc.vpc_id[0]
  subnet_id         = module.microk8s_subnet.subnet_id
  security_group_id = module.security_group.security_group_id[0]
  zone              = local.vpc_zones[0].zone
  ssh_key_ids       = local.ssh_key_ids
  tags              = local.tags
}

module "worker_node" {
  count             = var.worker_node_count
  source            = "./modules/compute"
  prefix            = "${local.prefix}-worker-${count.index + 1}"
  resource_group_id = local.resource_group_id
  vpc_id            = module.vpc.vpc_id[0]
  subnet_id         = module.microk8s_subnet.subnet_id
  security_group_id = module.security_group.security_group_id[0]
  zone              = local.vpc_zones[0].zone
  ssh_key_ids       = local.ssh_key_ids
  tags              = local.tags
}

module "cos" {
  create_cos_instance      = var.existing_cos_instance != "" ? false : true
  depends_on               = [module.vpc]
  source                   = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v6.10.0"
  resource_group_id        = local.resource_group_id
  region                   = var.region
  bucket_name              = "${local.prefix}-${local.vpc_zones[0].zone}-control-plane-bucket"
  create_cos_bucket        = true
  cos_instance_name        = (var.existing_cos_instance != "" ? null : "${local.prefix}-cos-instance")
  cos_tags                 = local.tags
  kms_encryption_enabled   = false
  existing_cos_instance_id = (var.existing_cos_instance != "" ? local.cos_instance : null)
}

module "worker_bucket" {
  create_cos_instance      = false
  depends_on               = [module.cos]
  source                   = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=v6.10.0"
  resource_group_id        = local.resource_group_id
  region                   = var.region
  bucket_name              = "${local.prefix}-${local.vpc_zones[0].zone}-worker-collector-bucket"
  create_cos_bucket        = true
  cos_tags                 = local.tags
  kms_encryption_enabled   = false
  existing_cos_instance_id = module.cos.cos_instance_id
}

resource "ibm_iam_authorization_policy" "cos_flowlogs" {
  count                       = var.existing_cos_instance != "" ? 0 : 1
  depends_on                  = [module.cos]
  source_service_name         = "is"
  source_resource_type        = "flow-log-collector"
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cos.cos_instance_guid
  roles                       = ["Writer", "Reader"]
}

resource "ibm_is_flow_log" "control_plane" {
  depends_on     = [ibm_iam_authorization_policy.cos_flowlogs]
  name           = "${local.prefix}-control-plane-subnet-collector"
  target         = module.vpc.subnet_ids[0]
  active         = true
  storage_bucket = module.cos.bucket_name
  resource_group = local.resource_group_id
}

resource "ibm_is_flow_log" "worker_nodes" {
  depends_on     = [ibm_is_flow_log.control_plane]
  name           = "${local.prefix}-worker-subnet-collector"
  target         = module.microk8s_subnet.subnet_id
  active         = true
  storage_bucket = module.worker_bucket.bucket_name
  resource_group = local.resource_group_id
}

module "ansible" {
  source            = "./ansible"
  bastion_public_ip = ibm_is_floating_ip.bastion.address
  controllers       = module.control_plane[*].instance[0]
  workers           = module.worker_node[*].instance[0]
  region            = var.region
  private_key_pem   = tls_private_key.ssh.private_key_pem
}

resource "null_resource" "ansible" {
  depends_on = [module.ansible]
  provisioner "local-exec" {
    command = "ssh-add ansible/generated_key_rsa"
  }
}