####################################################################################
### Karpenter
###
### Uses the Karpenter sub-module bundled with terraform-aws-modules/eks/aws v21.
### It provisions everything the controller needs:
###   - Controller IAM role + EKS Pod Identity association (no IRSA/OIDC wiring)
###   - Node IAM role + instance profile + EKS access entry for launched nodes
###   - SQS interruption queue + EventBridge rules (spot interruption, health events)
###
### Node/subnet/security-group discovery is driven by the "karpenter.sh/discovery"
### tag (= cluster name), applied to the private subnets and node security group
### in main.tf. The EC2NodeClass in k8s-manifests/karpenter matches that tag.
####################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = module.eks.cluster_name

  # The node IAM role name must match the `role` set in the EC2NodeClass manifest.
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = var.cluster_name

  # Use EKS Pod Identity (requires the eks-pod-identity-agent addon, enabled in main.tf)
  create_pod_identity_association = true

  # Allow SSM access on Karpenter-launched nodes
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name      = "${var.cluster_name}-karpenter"
    Terraform = "true"
  }
}

####################################################################################
### Karpenter controller Helm release
###
### Pinned to the node group labelled karpenter.sh/controller=true so the
### controller never runs on nodes it manages itself.
###
### NOTE: We pull the chart anonymously from public.ecr.aws and deliberately do
### NOT set repository_username/repository_password. Supplying ECR credentials
### makes the Helm provider perform an `oci registry login`, which on Windows
### writes to the Docker credential store and fails with
### "could not login to OCI registry ... The stub received bad data".
### public.ecr.aws allows unauthenticated pulls, so anonymous access avoids the
### broken login path entirely. (Docker-for-Windows credential-helper bug.)
####################################################################################
resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = var.karpenter_namespace
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_chart_version
  wait       = false

  values = [
    yamlencode({
      nodeSelector = {
        "karpenter.sh/controller" = "true"
      }
      dnsPolicy = "Default"
      settings = {
        clusterName       = module.eks.cluster_name
        clusterEndpoint   = module.eks.cluster_endpoint
        interruptionQueue = module.karpenter.queue_name
        enableZonalShift  = true
      }
      webhook = {
        enabled = false
      }
    })
  ]

  depends_on = [
    module.eks,
    module.karpenter,
    null_resource.update_kubeconfig
  ]
}
