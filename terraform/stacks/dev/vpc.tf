module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = "${var.project_name}-${var.env_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support

  # VPC Flow Logs
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  tags = merge(
    {
      Environment = var.env_name
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  vpc_tags = {
    Name = "${var.project_name}-${var.env_name}-vpc"
  }

  igw_tags = {
    Name = "${var.project_name}-${var.env_name}-igw"
  }

  nat_gateway_tags = {
    Name = "${var.project_name}-${var.env_name}-nat"
  }

  public_subnet_tags = {
    Type = "public"
  }

  private_subnet_tags = {
    Type = "private"
  }

  public_route_table_tags = {
    Name = "${var.project_name}-${var.env_name}-public-rt"
  }

  private_route_table_tags = {
    Name = "${var.project_name}-${var.env_name}-private-rt"
  }

}
