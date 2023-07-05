output "bastion_ssh_command" {
  depends_on  = [ibm_is_instance.bastion]
  description = "Connection info for the IBM Cloud Bastion Instance"
  value       = "ssh root@${ibm_is_floating_ip.bastion.address}"
}

output "ansible_playbook_command" {
  depends_on  = [module.ansible]
  description = "Run the following playbook to ping all hosts and check connectivity"
  value       = "ansible-playbook -i ansible/inventory ansible/playbooks/ping-all.yml"
}