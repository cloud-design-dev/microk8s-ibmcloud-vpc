resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      controllers = var.controllers
      bastion_ip  = var.bastion_public_ip
      workers     = var.workers
    }
  )
  filename = "${path.module}/inventory.ini"
}




# resource "local_file" "ansible_inventory_vars" {
#   content = templatefile("${path.module}/templates/deployment_vars.tmpl",
#     {
#       logging_key    = var.logging_key
#       monitoring_key = var.monitoring_key
#       region         = var.region
#     }
#   )
#   filename = "${path.module}/playbooks/deployment_vars.yml"
# }