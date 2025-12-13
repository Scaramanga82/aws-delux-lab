##########################################################
# General Configuration
##########################################################

aws_region    = "eu-west-2"
env_name      = "dev"
project_name  = "delux"
domain_name   = "kanazir.link"
domain_prefix = "dev"

##########################################################
# Cognito Configuration
##########################################################

cognito_user_pool_tier                = "PLUS"
cognito_advanced_security_mode        = "AUDIT"
cognito_mfa_configuration             = "OPTIONAL"
cognito_refresh_token_validity_days   = 5
cognito_access_token_validity_minutes = 60
cognito_id_token_validity_minutes     = 60


##########################################################
# VPC Configuration
##########################################################

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "eu-west-2a",
  "eu-west-2b",
  "eu-west-2c"
]

private_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

public_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24"
]

enable_nat_gateway      = true
single_nat_gateway      = true
