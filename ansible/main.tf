resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      bastion_ip  = var.bastion_public_ip
      controllers = var.controllers
      workers     = var.workers
    }
  )
  filename = "${path.module}/inventory.ini"
}

resource "local_file" "ssh-key" {
  content         = var.private_key_pem
  filename        = "${path.module}/generated_key_rsa"
  file_permission = "0600"
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