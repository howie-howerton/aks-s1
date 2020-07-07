terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "~> 2.17"
  features {}
}

provider "helm" {
  version = "~> 1.2"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.cluster.kube_config[0].host
    client_key             = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
    load_config_file       = false
  }
}

provider "kubernetes" {
  version                = "~> 1.11"
  load_config_file       = "false"
  host                   = azurerm_kubernetes_cluster.cluster.kube_config.0.host
  username               = azurerm_kubernetes_cluster.cluster.kube_config.0.username
  password               = azurerm_kubernetes_cluster.cluster.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = "aks-s1-demo"
  }
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = var.dns_prefix
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.kubernetes_version
  #   linux_profile {
  #     admin_username = "ubuntu"
  #     ssh_key {
  #       key_data = file(var.ssh_public_key)
  #     }
  #   }
  default_node_pool {
    name       = var.nodepool_name
    node_count = var.agent_count
    vm_size    = var.vm_size
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  tags = {
    Environment = "aks-s1-demo"
  }
}

# NEED TO CREATE A NAMESPACE AND A SECRET FOR S1 BEFORE RUNNING THE HELM PROVISIONER
resource "kubernetes_namespace" "s1" {
  metadata {
    name = var.s1_namespace
  }
  depends_on = [azurerm_kubernetes_cluster.cluster]
}

locals {
  dockerconfigjson = {
    "auths" = {
      (var.docker_server) = {
        username = var.docker_username
        password = var.docker_password
        auth     = base64encode(join(":", [var.docker_username, var.docker_password]))
      }
    }
  }
}

resource "kubernetes_secret" "s1" {
  metadata {
    name      = var.k8s_secret_for_s1_github_access_token
    namespace = var.s1_namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.s1, azurerm_kubernetes_cluster.cluster]
}

resource "helm_release" "local" {
  name      = var.helm_release_name
  chart     = "./cwpp_agent/helm_charts/sentinelone"
  namespace = kubernetes_namespace.s1.metadata[0].name
  set {
    name  = "image.imagePullSecrets[0].name"
    value = var.k8s_secret_for_s1_github_access_token
  }
  set {
    name  = "helper.image.repository"
    value = var.s1_helper_image_repository
  }
  set {
    name  = "helper.image.tag"
    value = var.s1_helper_image_tag
  }
  set {
    name  = "helper.env.cluster"
    value = var.cluster_name
  }
  set {
    name  = "agent.image.repository"
    value = var.s1_agent_image_repository
  }
  set {
    name  = "agent.image.tag"
    value = var.s1_agent_image_tag
  }
  set {
    name  = "agent.env.site_key"
    value = var.s1_site_key
  }
  depends_on = [kubernetes_namespace.s1, kubernetes_secret.s1]
}

