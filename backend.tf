terraform {
  cloud {
    organization = "cde-dev"
    workspaces {
      name = "microk8s-testing-workspace"
    }
  }
}
