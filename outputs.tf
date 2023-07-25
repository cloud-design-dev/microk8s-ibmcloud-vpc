output "step_01_ping_hosts" {
  depends_on  = [module.ansible]
  description = "Run the following playbook to ping all hosts and check connectivity"
  value       = "ansible-playbook -i ansible/inventory.ini ansible/playbooks/ping-all.yml"
}

output "step_02_update_hosts" {
  depends_on  = [module.ansible]
  description = "Run the following playbook to update systems and install obersevability tools"
  value       = "ansible-playbook -i ansible/inventory.ini ansible/playbooks/update-systems.yml"
}

output "step_03_deploy_cluster" {
  depends_on  = [module.ansible]
  description = "Run the following playbook to create the microk8s cluster"
  value       = "ansible-playbook -i ansible/inventory.ini ansible/playbooks/configure-microk8s.yml"
}

output "bastion_ip" {
  depends_on  = [module.bastion]
  description = "Bastion Public IP"
  value       = ibm_is_floating_ip.bastion.address
}
