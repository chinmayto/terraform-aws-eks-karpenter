variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "CT-EKS-Cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster. Passed to the EKS module as `kubernetes_version`."
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

####################################################################################
### Karpenter Variables
####################################################################################
variable "karpenter_chart_version" {
  description = "Version of the Karpenter Helm chart to install (oci://public.ecr.aws/karpenter/karpenter)"
  type        = string
  default     = "1.6.0"
}

variable "karpenter_namespace" {
  description = "Namespace where the Karpenter controller is installed"
  type        = string
  default     = "kube-system"
}
