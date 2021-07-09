output "cluster_name" {
  value = var.cluster_name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_profile" {
  value = var.aws_profile
}

output "aws_region" {
  value = var.aws_region
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "Use this with github.com/relaxdiego/ssh4realz to ssh to the bastion for the first time"
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "db_name" {
  value = aws_db_instance.db.name
}

output "k8s_cluster_name" {
  value = aws_eks_cluster.k8s.name
}

output "k8s_cluster_arn" {
  value = aws_eks_cluster.k8s.arn
}

output "k8s_endpoint" {
  value = aws_eks_cluster.k8s.endpoint
}

output "k8s_cacert_data" {
  value = aws_eks_cluster.k8s.certificate_authority[0].data
}

output "registry_frontend" {
  value = aws_ecr_repository.frontend.repository_url
}

output "registry_api" {
  value = aws_ecr_repository.api.repository_url
}

output "cert_manager_role_arn" {
  value = aws_iam_role.cert_manager.arn
}
