resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      control_plane_instances = var.control_plane_instances
      worker_instances        = var.worker_instances
      bastion_ip              = var.bastion_ip
    }
  )
  filename = "${path.module}/inventory"
}

resource "local_file" "ansible_inventory_vars" {
  content = templatefile("${path.module}/templates/deployment_vars.tmpl",
    {
      logging_key    = var.logging_key
      monitoring_key = var.monitoring_key
      region         = var.region
    }
  )
  filename = "${path.module}/playbooks/deployment_vars.yml"
}