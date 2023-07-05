provider "ibm" {
  region = var.region
}

provider "logdna" {
  alias      = "at"
  servicekey = module.observability.activity_tracker_resource_key != null ? module.observability.activity_tracker_resource_key : ""
  url        = local.at_endpoint
}

provider "logdna" {
  alias      = "ld"
  servicekey = module.observability.log_analysis_resource_key != null ? module.observability.log_analysis_resource_key : ""
  url        = local.at_endpoint
}

provider "packer" {
}