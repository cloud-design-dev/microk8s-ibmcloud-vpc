# output "step_01_ping_hosts" {
#   depends_on  = [module.ansible]
#   description = "Run the following playbook to ping all hosts and check connectivity"
#   value       = "ansible-playbook -i ansible/inventory ansible/playbooks/ping-all.yml"
# }

# output "step_02_update_hosts" {
#   depends_on  = [module.ansible]
#   description = "Run the following playbook to update systems and install obersevability tools"
#   value       = "ansible-playbook -i ansible/inventory ansible/playbooks/main.yml"
# }

# output "step_03_deploy_cluster" {
#   depends_on  = [module.ansible]
#   description = "Run the following playbook to create the microk8s cluster"
#   value       = "ansible-playbook -i ansible/inventory ansible/playbooks/deploy-microk8s.yml"
# }