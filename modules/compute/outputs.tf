output "primary_network_interface" {
  value = ibm_is_instance.compute.primary_network_interface[0].id
}

output "instances" {
  value = ibm_is_instance.compute
}