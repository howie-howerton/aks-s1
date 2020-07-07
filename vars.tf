variable "client_id" {
  description = "The client_id that K8s uses when creating Azure load balancers.  Can be the same as the client_id that terraform uses to create the cluster."
}

variable "client_secret" {
  description = "The client_secret that K8s uses when creating Azure load balancers.  Can be the same as the client_secret that terraform uses to create the cluster."
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create."
  default     = "aks-s1-rg"
}
variable "location" {
  description = "The preferred Region into which to launch the resources outlined in this template."
  default     = "eastus"
}
variable "cluster_name" {
  description = "Cluster name for the AKS cluster"
  default     = "aks-s1-demo"
}

variable "dns_prefix" {
  description = "The DNS prefix that forms part of the FQDN used to access the cluster.  dns_prefix must contain between 2 and 45 characters. The name can contain only letters, numbers, and hyphens. The name must start with a letter and must end with an alphanumeric character."
  default     = "aks-s1-demo"
}

variable "agent_count" {
  description = "Number of worker nodes for the cluster."
  default     = "2"
}

variable "kubernetes_version" {
  description = "The version of Kuberentes to use."
  default     = "1.18.2"
}

# variable "admin_username" {
#   description = "The name of the admin user for each K8s worker node.  Used with SSH logins."
#   default     = "ubuntu"
# }

variable "vm_size" {
  description = "Azure VM size to use for the K8s worker nodes."
  default     = "Standard_D2s_v3"
}

variable "nodepool_name" {
  description = "The name to be used for the AKS cluster's nodepool."
  default     = "nodepool"
}

# variable "ssh_public_key" {
#   description = "Path to the SSH public key to be used to log into the worker nodes (if necessary).."
# }

variable "k8s_secret_for_s1_github_access_token" {
  description = "This is the NAME of the K8s secret that stores your GitHub token (that is used to authenticate to the S1 GitHub packages repository (where the s1-agent and s1-helper Docker images are stored.))"
  # ie: You need to get your gihub token via your account team (as of March 6th 2020)
}

variable "service_account_name" {
  description = "Service Account Name to use"
  default     = "sentinelone"
}

variable "s1_helper_image_repository" {
  description = "The image/package repository where the s1_helper image is located."
  default     = "docker.pkg.github.com/s1-agents/cwpp_agent/s1helper"
}

variable "s1_helper_image_tag" {
  description = "Tag name (version) of the s1_helper image we want to use"
  default     = "ga-4.2.2"
}


variable "s1_agent_image_repository" {
  description = "The image/package repository where the s1_agent image is located."
  default     = "docker.pkg.github.com/s1-agents/cwpp_agent/s1agent"
}

variable "s1_agent_image_tag" {
  description = "Tag name (version) of the s1_agent image we want to use"
  default     = "ga-4.2.2"
}

variable "s1_site_key" {
  description = "The Sentinel One Site Key that the CWPP agent will use when communicating with the S1 portal."
}

variable "s1_namespace" {
  description = "K8s namespace into which we will place the S1 cwpp agent(s)"
  default     = "s1"
}

variable "docker_server" {
  description = "Base Repo that houses S1 Docker images"
  default     = "docker.pkg.github.com"
}

variable "docker_username" {
  description = "Need more info as to why this is necessary.  It seems to be the username you use for Git when accessing GitHub." # ToDo:  Investigate why/if this is needed.
}

variable "docker_password" {
  description = "GitHub access token to access the GitHub package/image repository (where the s1-agent and s1-helper images live)."
}

variable "helm_release_name" {
  description = "Helm Releaes Name to use for the Helm deployment"
  default     = "s1"
}