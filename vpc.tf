# 1. Crea una VPC dedicada para EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"  # Rango de IPs privadas
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-eks-ecommerce"
  }
}

# 2. Subnets Públicas (para recursos accesibles desde Internet)
resource "aws_subnet" "public_subnets" {
  count             = 3  # Creará 3 subnets en distintas AZs
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"  # Ej: 10.0.1.0/24, 10.0.2.0/24, etc.
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"  # AZs: us-east-1a, us-east-1b, us-east-1c

  tags = {
    Name = "subnet-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"  # Necesario para EKS
  }
}

# 3. Subnets Privadas (para nodos de EKS)
resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 4}.0/24"  # Ej: 10.0.4.0/24, 10.0.5.0/24, etc.
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"

  tags = {
    Name = "subnet-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"  # Necesario para EKS
  }
}

# 4. Internet Gateway (para conexión a Internet en subnets públicas)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "igw-eks"
  }
}

# 5. Route Table para subnets públicas
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-public"
  }
}

# 6. Asocia las subnets públicas a la route table
resource "aws_route_table_association" "public_rta" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# 7. NAT Gateway (para que las subnets privadas tengan salida a Internet)
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id  # Se crea en la primera subnet pública

  tags = {
    Name = "nat-gw-eks"
  }
}

# 8. Route Table para subnets privadas
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "rt-private"
  }
}

# 9. Asocia las subnets privadas a la route table
resource "aws_route_table_association" "private_rta" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}