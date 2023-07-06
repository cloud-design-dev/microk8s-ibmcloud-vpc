locals {
  prefix      = "${random_string.prefix.result}-lab"
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