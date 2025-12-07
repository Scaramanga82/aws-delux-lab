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

cognito_user_pool_tier                = "ESSENTIALS"
cognito_advanced_security_mode        = "AUDIT"
cognito_mfa_configuration             = "OPTIONAL"
cognito_refresh_token_validity_days   = 5
cognito_access_token_validity_minutes = 60
cognito_id_token_validity_minutes     = 60
