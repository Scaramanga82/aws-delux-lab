# resource "aws_instance" "client_vpn_ec2" {
#   count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_client_vpn_ec2") ? 1 : 0

#   ami                         = var.client_vpn_ec2_ami[var.environment_code]
#   instance_type               = var.client_vpn_ec2_instance_type[var.environment_code]
#   key_name                    = var.client_vpn_ec2_instance_key[var.environment_code]
#   subnet_id                   = var.client_vpn_ec2_instance_subnet[var.environment_code]
#   associate_public_ip_address = true

#   vpc_security_group_ids = [
#     aws_security_group.client_vpn_ec2_sg.id
#   ]

#   root_block_device {
#     volume_size           = "20"
#     volume_type           = "gp3"
#     encrypted             = false 
#   }
  
#   tags = {
#     Name              = format("%s-%s-%s", var.project_name, var.environment_code, "client-vpn")
#     Environment       = var.environment_code
#     Owner             = var.team_name
#     DataTeam-AWS-Cost = var.data_cost
#  }
# }


# resource "aws_security_group" "client_vpn_ec2_sg" {
#   vpc_id = aws_vpc.vpc.id
#   name   = format("%s-%s-%s", var.project_name, var.environment_code, "client-vpn-security-group")

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name              = format("%s-%s-%s", var.project_name, var.environment_code, "client-vpn-security-group")
#     Environment       = var.environment_code
#     Owner             = var.team_name
#     DataTeam-AWS-Cost = var.data_cost
#   }
# }


# resource "aws_security_group" "client_vpn_endpoint_sg" {
#   vpc_id = aws_vpc.vpc.id
#   name   = format("%s-%s-%s", var.project_name, var.environment_code, "client-endpoint-security-group")

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Incoming VPN connection"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name              = format("%s-%s-%s", var.project_name, var.environment_code, "client-endpoint-security-group")
#     Environment       = var.environment_code
#     Owner             = var.team_name
#     DataTeam-AWS-Cost = var.data_cost
#   }
# }


# resource "aws_ec2_client_vpn_endpoint" "client_endpoint_vpn" {
#   description            = format("%s-%s-%s", var.project_name, var.environment_code, "client-vpn")
#   server_certificate_arn = var.server_cert[var.environment_code]
#   client_cidr_block      = "192.168.0.0/22"
#   security_group_ids = [aws_security_group.client_vpn_endpoint_sg.id]
#   vpc_id = aws_vpc.vpc.id
#   split_tunnel = true

#   authentication_options {
#     type                       = "certificate-authentication"
#     root_certificate_chain_arn = var.client_cert[var.environment_code]
#   }

#   connection_log_options {
#     enabled               = false
#  }

#   tags = {
#     Name              = format("%s-%s-%s", var.project_name, var.environment_code, "client-vpn")
#     Environment       = var.environment_code
#     Owner             = var.team_name
#     DataTeam-AWS-Cost = var.data_cost
#   }
# }

# resource "aws_ec2_client_vpn_network_association" "client_endpoint_vpn_network_association" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_endpoint_vpn.id
#   subnet_id              = var.target_vpn_subnet_id[var.environment_code]
# }

# resource "aws_ec2_client_vpn_route" "client_endpoint_vpn_route" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_endpoint_vpn.id
#   destination_cidr_block = "0.0.0.0/0"
#   target_vpc_subnet_id   = var.target_vpn_subnet_id[var.environment_code]
# }

# resource "aws_ec2_client_vpn_authorization_rule" "client_endpoint_vpn_authorization_rule" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_endpoint_vpn.id
#   target_network_cidr    = "0.0.0.0/0"
#   authorize_all_groups   = true
# }
