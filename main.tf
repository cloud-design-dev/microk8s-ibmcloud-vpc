# Generate a random string if a project prefix was not provided
resource "random_string" "prefix" {
  count   = var.project_prefix != "" || var.project_prefix != null ? 0 : 1
  length  = 4
  special = false
  upper   = false
  numeric = false
}

# Generate a new SSH key if one was not provided
resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add a new SSH key to the region if one was created
resource "ibm_is_ssh_key" "generated_key" {
  count          = var.existing_ssh_key != "" ? 0 : 1
  name           = "${local.prefix}-${var.region}-key"
  public_key     = tls_private_key.ssh.0.public_key_openssh
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

# Write private key to file if it was generated
resource "null_resource" "create_private_key" {
  count = var.existing_ssh_key != "" ? 0 : 1
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.ssh.0.private_key_pem}' > ./'${local.prefix}'.pem
      chmod 400 ./'${local.prefix}'.pem
    EOT
  }
}

# IF a resource group was not provided, create a new one
module "resource_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

module "vpc" {
  source                      = "terraform-ibm-modules/vpc/ibm//modules/vpc"
  version                     = "1.1.1"
  create_vpc                  = true
  vpc_name                    = "${local.prefix}-vpc"
  resource_group_id           = module.resource_group.resource_group_id
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
  resource_group_id     = module.resource_group.resource_group_id
  security_group_rules  = local.frontend_rules
}

module "microk8s_subnet" {
  source              = "terraform-ibm-modules/vpc/ibm//modules/subnet"
  version             = "1.1.1"
  name                = "${local.prefix}-microk8s-subnet"
  vpc_id              = module.vpc.vpc_id[0]
  resource_group_id   = module.resource_group.resource_group_id
  location            = local.vpc_zones[0].zone
  number_of_addresses = var.number_of_addresses
  public_gateway      = module.vpc.public_gateway_ids[0]
}

module "observability" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=main"
  providers = {
    logdna.at = logdna.at
    logdna.ld = logdna.ld
  }
  resource_group_id              = module.resource_group.resource_group_id
  region                         = var.region
  cloud_monitoring_provision     = true
  cloud_monitoring_instance_name = "${local.prefix}-monitoring-instance"
  enable_platform_metrics        = false
  cloud_monitoring_plan          = "graduated-tier"
  cloud_monitoring_tags          = local.tags
  activity_tracker_provision     = false
  log_analysis_provision         = true
  log_analysis_instance_name     = "${local.prefix}-logging-instance"
  log_analysis_plan              = "7-day"
  log_analysis_tags              = local.tags
}

module "bastion" {
  source            = "./modules/compute"
  prefix            = "${local.prefix}-bastion"
  resource_group_id = module.resource_group.resource_group_id
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
  resource_group = module.resource_group.resource_group_id
  tags           = local.tags
}

module "control_plane" {
  count             = 3
  source            = "./modules/compute"
  prefix            = "${local.prefix}-control-plane-${count.index + 1}"
  resource_group_id = module.resource_group.resource_group_id
  vpc_id            = module.vpc.vpc_id[0]
  subnet_id         = module.microk8s_subnet.subnet_id
  security_group_id = module.security_group.security_group_id[0]
  zone              = local.vpc_zones[0].zone
  ssh_key_ids       = local.ssh_key_ids
  tags              = local.tags
}

module "worker_node" {
  count             = 3
  source            = "./modules/compute"
  prefix            = "${local.prefix}-worker-node-${count.index + 1}"
  resource_group_id = module.resource_group.resource_group_id
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
  resource_group_id        = module.resource_group.resource_group_id
  region                   = var.region
  bucket_name              = "${local.prefix}-${local.vpc_zones[0].zone}-control-plane-bucket"
  create_cos_bucket        = true
  cos_instance_name        = (var.existing_cos_instance != "" ? null : "${local.prefix}-cos-instance")
  cos_tags                 = local.tags
  kms_encryption_enabled   = false
  existing_cos_instance_id = (var.existing_cos_instance != "" ? local.cos_instance : null)
}

module "flowlog_buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "6.10.0" # Replace "latest" with a release version to lock into a specific release
  bucket_configs = [
    {
      bucket_name            = "${local.prefix}-${local.vpc_zones[0].zone}-worker-node-1-bucket"
      region_location        = var.region
      kms_encryption_enabled = false
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos.cos_instance_id
    },
    {
      bucket_name            = "${local.prefix}-${local.vpc_zones[0].zone}-worker-node-2-bucket"
      region_location        = var.region
      kms_encryption_enabled = false
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos.cos_instance_id
    },
    {
      bucket_name            = "${local.prefix}-${local.vpc_zones[0].zone}-worker-node-3-bucket"
      region_location        = var.region
      kms_encryption_enabled = false
      resource_group_id      = module.resource_group.resource_group_id
      resource_instance_id   = module.cos.cos_instance_id
    }
  ]
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
}

resource "ibm_is_flow_log" "worker_nodes" {
  count          = 3
  depends_on     = [ibm_is_flow_log.control_plane]
  name           = "${local.prefix}-worker-node-${count.index + 1}-collector"
  target         = module.worker_node[count.index].primary_network_interface
  active         = true
  storage_bucket = module.flowlog_buckets.bucket_configs[count.index].bucket_name
}

module "ansible" {
  source                  = "./ansible"
  control_plane_instances = module.control_plane[*].instance[0]
  worker_instances        = module.worker_node[*].instance[0]
  bastion_ip              = ibm_is_floating_ip.bastion.address
  logging_key             = module.observability.log_analysis_ingestion_key
  monitoring_key          = module.observability.cloud_monitoring_access_key
  region                  = var.region
}
