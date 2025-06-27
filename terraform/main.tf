# terraform/main.tf

# Configure AWS Provider
provider "aws" {
  region = var.region
}

# --- Networking Resources ---

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway for public subnet access
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Data source to get available AZs for the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true # Instances in public subnet get public IPs
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name                     = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1" # Tag for Kubernetes Load Balancer
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count               = length(var.private_subnet_cidr_blocks)
  vpc_id              = aws_vpc.main.id
  cidr_block          = var.private_subnet_cidr_blocks[count.index]
  availability_zone   = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name                          = "${var.project_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1" # Tag for Kubernetes Internal Load Balancer
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- IAM Roles for EKS ---

# IAM Role for EKS Cluster Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonEKSClusterPolicy to the EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


# IAM Role for EKS Node Group (Worker Nodes)
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AmazonEKSWorkerNodePolicy to the EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_node_policy_attach_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# Attach AmazonEC2ContainerRegistryReadOnly to the EKS Node Role (for pulling ECR images)
resource "aws_iam_role_policy_attachment" "eks_node_policy_attach_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Attach AmazonEKS_CNI_Policy to the EKS Node Role (for network interface)
resource "aws_iam_role_policy_attachment" "eks_node_policy_attach_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}
# terraform/main.tf (append this to your existing content)

# --- EKS Cluster ---

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.28" # Specify your desired Kubernetes version (e.g., "1.28", "1.29")

  vpc_config {
    subnet_ids         = concat(aws_subnet.public.*.id, aws_subnet.private.*.id)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs = ["0.0.0.0/0"] # Be cautious: this allows public access from anywhere. Restrict in production.
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attach
  ]

  tags = {
    Name = "${var.project_name}-eks-cluster"
  }
}

# --- EKS Node Group ---

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.private.*.id # Typically, worker nodes are in private subnets

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"] # Choose an instance type that fits your needs
  desired_size   = 2             # Number of worker nodes
  max_size       = 3
  min_size       = 1

  ami_type       = "AL2_x86_64" # Amazon Linux 2 (recommended for EKS)

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and attached to the EKS Node Group.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy_attach_worker,
    aws_iam_role_policy_attachment.eks_node_policy_attach_ecr,
    aws_iam_role_policy_attachment.eks_node_policy_attach_cni,
  ]

  tags = {
    Name = "${var.project_name}-eks-node-group"
    "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "owned" # Required for cluster auto-scaling
  }
}
