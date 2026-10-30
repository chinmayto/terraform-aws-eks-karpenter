output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

################################################################################
# Karpenter Outputs
################################################################################
output "karpenter_node_iam_role_name" {
  description = "IAM role name used by Karpenter-provisioned nodes (referenced by the EC2NodeClass)"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_queue_name" {
  description = "Name of the SQS interruption queue consumed by the Karpenter controller"
  value       = module.karpenter.queue_name
}

output "karpenter_discovery_tag" {
  description = "Value of the karpenter.sh/discovery tag used for subnet/security-group auto-discovery"
  value       = var.cluster_name
}
