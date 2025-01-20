provider "aws" {
  region = var.region
}

resource "aws_iam_user" "example_user" {
  name = var.user_name
}

resource "aws_iam_access_key" "example_user_key" {
  user = aws_iam_user.example_user.name
}

resource "aws_controltower_account" "example_account" {
  account_name = var.user_name
  email       = "example@example.com"
  organizational_unit = var.org_unit
  role_name   = "AWSControlTowerExecution"
}

resource "aws_controltower_account" "example_account" {
  account_name = var.user_name
  email       = "example@example.com"
  organizational_unit = var.org_unit
  role_name   = "AWSControlTowerExecution"
}
