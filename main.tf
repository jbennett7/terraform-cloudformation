variable "division" {
  default = "Corporate"
}

variable "assume_role_arn" {
  default = "arn:aws:iam::299840366891:role/test-role"
}

variable "template_url" {
  default = "https://cf-templates-1mewyk1u4ziy1-us-east-1.s3.amazonaws.com/main.yaml"
}

variable "stack_name" {}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = var.assume_role_arn
    session_name = "aws-splunk-integration"
  }
}

data "aws_vpcs" "vpcs" {}

locals {
  vpc_ids = tolist(data.aws_vpcs.vpcs.ids)
  vpc_param = tolist(slice([ "VpcId", "VpcId2", "VpcId3", "VpcId4", "VpcId5" ], 0, length(local.vpc_ids)))
  parameters = merge({"Division" = var.division }, zipmap(local.vpc_param, local.vpc_ids))
}

resource "aws_cloudformation_stack" "splunk_integration" {
  name = var.stack_name
  parameters = local.parameters
  template_url = var.template_url
  capabilities = [
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND"
  ]
  disable_rollback = false
}

output "parameter_list" {
  value = local.parameters
}

output "aws_cloudformation_stack_id" {
  value = aws_cloudformation_stack.splunk_integration.id
}
