locals {
  prefix       = var.project_prefix != "" || var.project_prefix != null ? var.project_prefix : "${random_string.prefix.0.result}"
  ssh_key_ids  = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.sshkey[0].id] : [ibm_is_ssh_key.generated_key[0].id]
  cos_instance = var.existing_cos_instance != "" || var.existing_cos_instance != null ? data.ibm_resource_instance.cos.0.id : null
  cos_guid     = var.existing_cos_instance != "" || var.existing_cos_instance != null ? data.ibm_resource_instance.cos.0.guid : substr(trim(trimprefix(module.cos.cos_instance_id, "crn:v1:bluemix:public:cloud-object-storage:global:a/"), "::"), 33, -1)

  at_endpoint = "https://api.${var.region}.logging.cloud.ibm.com"
  deploy_date = formatdate("YYYYMMDD", timestamp())

  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.region}-${zone + 1}"
    }
  }

  frontend_rules = [
    for r in var.frontend_rules : {
      name       = r.name
      direction  = r.direction
      remote     = lookup(r, "remote", null)
      ip_version = lookup(r, "ip_version", null)
      icmp       = lookup(r, "icmp", null)
      tcp        = lookup(r, "tcp", null)
      udp        = lookup(r, "udp", null)
    }
  ]

  tags = [
    "provider:ibm",
    "workspace:${terraform.workspace}",
  ]
}