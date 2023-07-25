locals {
  prefix            = random_string.prefix.result
  resource_group_id = var.existing_resource_group != "" ? data.ibm_resource_group.resource_group[0].id : module.resource_group[0].resource_group_id
  ssh_key_ids       = var.existing_ssh_key != "" ? [data.ibm_is_ssh_key.sshkey[0].id, ibm_is_ssh_key.generated_key.id] : [ibm_is_ssh_key.generated_key.id]
  cos_instance      = var.existing_cos_instance != "" ? data.ibm_resource_instance.cos.0.id : null
  cos_guid          = var.existing_cos_instance != "" ? data.ibm_resource_instance.cos.0.guid : module.cos.cos_instance_guid

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
    "owner:${var.owner}"
  ]
}
