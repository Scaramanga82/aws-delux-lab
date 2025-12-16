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

enable_nat_gateway = true
single_nat_gateway = true

##########################################################
# Aurora PostgreSQL Configuration
##########################################################

aurora_postgresql_engine_version        = "17.4"
aurora_postgresql_instance_class        = "db.t3.medium"
aurora_postgresql_backup_retention_days = 1
aurora_postgresql_backup_window         = "03:00-04:00"
aurora_postgresql_maintenance_window    = "sun:04:00-sun:05:00"

##########################################################
# ECS Configuration
##########################################################

ecs_container_port   = 80
ecs_health_check_path = "/"
ecs_cpu              = 256
ecs_memory           = 512
ecs_desired_count    = 1
ecs_image            = "220027435491.dkr.ecr.eu-west-2.amazonaws.com/kanazir-ecr:latest"

##########################################################
# Frontend Configuration
##########################################################

frontend_domain                      = "cdn.dev.kanazir.link"
cloudfront_price_class               = "PriceClass_100"  # US, Canada, Europe
cloudfront_geo_restriction_type      = "none"
cloudfront_geo_restriction_locations = []
cloudfront_log_retention_days        = 30  # Dev: 30 days

##########################################################
# WAF Configuration
##########################################################

waf_rate_limit         = 2000  # 2000 requests per 5 min per IP
waf_blocked_countries  = []    # No blocking for dev
waf_log_retention_days = 30
