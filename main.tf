provider "aws" {
  region = "us-east-1"
}

data "aws_iam_role" "labrole-arn" {
    name = "LabRole"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19"

  cluster_name    = "ecommerce-cluster"
  cluster_version = "1.30"
  enable_irsa = false
  
  cluster_endpoint_public_access  = true

  vpc_id                   = aws_vpc.eks_vpc.id
  subnet_ids               = concat(aws_subnet.private_subnets[*].id, aws_subnet.public_subnets[*].id)
  control_plane_subnet_ids = aws_subnet.private_subnets[*].id
  iam_role_arn = data.aws_iam_role.labrole-arn.arn
  create_iam_role = false

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND" #Fijo para evitar costos inesperados de Spot
  }

  eks_managed_node_groups = {
    workers = {
      min_size     = 2 #Tolerancia a fallas, por eso minimo 2 nodos
      max_size     = 5 #Escalabilidad hasta 5 nodos
      desired_size = 2

      instance_types = ["t3.medium", "t3.large"]  #Opciones para escalar
      capacity_type  = "ON_DEMAND"
      subnet_ids = aws_subnet.private_subnets[*].id

      iam_role_arn = data.aws_iam_role.labrole-arn.arn
      iam_instance_profile_arn = data.aws_iam_role.labrole-arn.arn
      create_iam_role = false
      create_role = false

      tags = {  # Tags para costos y organización
        Environment = "production"
        Project     = "ecommerce"
    }
  }
}
}