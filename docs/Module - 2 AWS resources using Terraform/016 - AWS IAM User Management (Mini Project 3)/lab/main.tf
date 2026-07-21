data "aws_caller_identity" "current" {}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_user" "users" {
  for_each = {for user in local.users: user.first_name => user}

  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  path   = "/users/"

  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department" = each.value.department
    "JobTitle" = each.value.job_title
  }
}

resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users 

  user = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [ password_reset_required, password_length ]
  }
}

resource "aws_iam_policy" "enforce_mfa" {
  name        = "EnforceMFA"
  path        = "/"
  description = "Denies all access unless user is logged in with MFA"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/users/*"
        ]
      },
      {
        Sid    = "DenyAllExceptMFASetupIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "managers_mfa" {
  group      = aws_iam_group.managers.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

resource "aws_iam_group_policy_attachment" "education_mfa" {
  group      = aws_iam_group.education.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

resource "aws_iam_group_policy_attachment" "engneers_mfa" {
  group      = aws_iam_group.engneers.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}
