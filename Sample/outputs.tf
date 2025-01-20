output "user_access_key_id" {
  value = aws_iam_access_key.example_user_key.id
}

output "user_secret_access_key" {
  value = aws_iam_access_key.example_user_key.secret
}

output "control_tower_account_id" {
  value = aws_controltower_account.example_account.id
}

output "control_tower_account_email" {
  value = aws_controltower_account.example_account.email
}
