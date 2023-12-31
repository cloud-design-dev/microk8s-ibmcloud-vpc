variable "ibmcloud_api_key" {
  description = "IBM Cloud API key needed to deploy the resources"
  type        = string
}

variable "existing_resource_group" {
  description = "Name of an existing Resource Group to use for resources. If not set, a new Resource Group will be created."
  type        = string
  default     = ""
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  type        = string
}

variable "classic_access" {
  description = "Allow classic access to the VPC."
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The address prefix to use for the VPC. Default is set to auto."
  type        = string
  default     = "auto"
}

variable "number_of_addresses" {
  description = "Number of IPs to assign for each subnet."
  type        = number
  default     = 128
}

variable "owner" {
  description = "Owner declaration for resource tags. e.g. 'ryantiffany'"
  type        = string
}

variable "existing_ssh_key" {
  description = "Name of an existing SSH key to use for the VPC. If not set, a new SSH key will be created."
  type        = string
  default     = ""
}

variable "existing_cos_instance" {
  description = "Name of an existing Object Storage instance to use for the VPC Flowlog collectors. If not set, a new Object Storage instance will be created."
  type        = string
  default     = ""
}

variable "controller_node_count" {
  description = "Number of microk8s controller nodes to create."
  type        = number
  default     = 1
}

variable "worker_node_count" {
  description = "Number of microk8s worker nodes to create."
  type        = number
  default     = 3
}

variable "frontend_rules" {
  description = "A list of security group rules to be added to the microk8s security group"
  type = list(
    object({
      name      = string
      direction = string
      remote    = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )

  validation {
    error_message = "Security group rules can only have one of `icmp`, `udp`, or `tcp`."
    condition = (var.frontend_rules == null || length(var.frontend_rules) == 0) ? true : length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.frontend_rules :
        # Return true if there is more than one of `icmp`, `udp`, or `tcp`
        true if length(
          [
            for type in ["tcp", "udp", "icmp"] :
            true if rule[type] != null
          ]
        ) > 1
      ])
    )) == 0 # Checks for length. If all fields all correct, array will be empty
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = (var.frontend_rules == null || length(var.frontend_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.frontend_rules :
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition = (var.frontend_rules == null || length(var.frontend_rules) == 0) ? true : length(distinct(
      flatten([
        # Check through rules
        for rule in var.frontend_rules :
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }

  default = [
    {
      name       = "inbound-http"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name       = "inbound-https"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 443
        port_max = 443
      }
    },
    {
      name       = "inbound-ssh"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name       = "inbound-cluster-join"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 25000
        port_max = 25000
      }
    },
    {
      name       = "inbound-icmp"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      icmp = {
        code = 0
        type = 8
      }
    },
    {
      name       = "microk8s-api-inbound"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 16443
        port_max = 16443
      }
    },
    {
      name       = "services-outbound"
      direction  = "outbound"
      remote     = "161.26.0.0/16"
      ip_version = "ipv4"
    },
    {
      name       = "all-outbound"
      direction  = "outbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
    }
  ]
}
