variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "ap-southeast-1"
}

variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}

variable "org_unit" {
  description = "The organizational unit for the account"
  type        = string
}

variable "control_tower_ou_name" {
  description = "The name of the AWS Control Tower OU"
  type        = string
}

variable "control_tower_account_name" {
  description = "The name of the AWS Control Tower account"
  type        = string
}
