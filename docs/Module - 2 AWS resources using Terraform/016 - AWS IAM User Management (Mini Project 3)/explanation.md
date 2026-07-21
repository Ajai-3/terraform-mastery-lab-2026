# AWS IAM User Management - Code Explanation

This document provides a detailed resource-by-resource and line-by-line explanation of the Infrastructure as Code (IaC) configuration inside the [`lab/`](./lab/) directory for the IAM User Management Mini Project.

---

## 1. Provider & Backend Configurations

### `provider.tf`
```terraform
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
```
* **AWS Provider**: Sets up HashiCorp's AWS provider (v6.x) pointing to `us-east-1` as the default deployment region.

### `backend.tf`
```terraform
terraform {
  backend "s3" {
    bucket = "terraform-backend-bucket-mini-project-3"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}
```
* **S3 State Storage**: Configures a secure remote S3 backend with lockfile support to store state files safely and prevent collision errors.

---

## 2. Variables and Inputs

### `variables.tf` & `terraform.tfvars`
* Defines project environments (`environment = "dev"`) and the target AWS region (`region = "us-east-1"`).

### `users.csv`
* A comma-separated list storing user profiles (`first_name,last_name,department,job_title`). This works as our database roster for user provisioning.

---

## 3. Data Processing (`local.tf`)

```terraform
locals {
  users = csvdecode(file("${path.module}/users.csv"))
}
```
* **`csvdecode`**: Reads the local CSV file and decodes it. It turns each row into an object map:
  ```json
  {
    "first_name": "Michael",
    "last_name": "Scott",
    "department": "Education",
    "job_title": "Regional Manager"
  }
  ```

---

## 4. Main Infrastructure Configurations (`main.tf`)

### Dynamic User Provisioning
```terraform
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
```
* **`for_each`**: Iterates through each user map decoded from the CSV.
* **`name`**: Dynamically constructs a standard username using the first character of their first name combined with their last name, completely in lowercase (e.g. `Michael Scott` becomes `mscott`).
* **`tags`**: Attaches metadata to the AWS user profile for department categorization.

### User Security Profiles & Initial Passwords
```terraform
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users 

  user = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [ password_reset_required, password_length ]
  }
}
```
* **`aws_iam_user_login_profile`**: Creates a console login profile for each user, assigning them an auto-generated temporary password.
* **`password_reset_required = true`**: Enforces a password reset during their first login.
* **`lifecycle { ignore_changes = [...] }`**: Prevents Terraform from overwriting or changing user password status if they update it later in the AWS Console.

### MFA Enforcer Policy
```terraform
resource "aws_iam_policy" "enforce_mfa" {
  name        = "EnforceMFA"
  # ...
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
      # ...
      {
        Sid    = "DenyAllExceptMFASetupIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          # ...
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
```
* **JSON Policy**: Defines a policy called `EnforceMFA`.
  - Statement 1 allows users to perform basic operations (getting password policies, resetting their own password, and viewing MFA details).
  - Statement 2 allows managing their own MFA devices under their resource ARN.
  - Statement 3 explicitly **denies** all other actions if they are not logged in using MFA (`aws:MultiFactorAuthPresent = "false"`).

---

## 5. Groups & Group Memberships (`groups.tf`)

```terraform
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}
# ... (similar group declarations for Engneers and Managers)
```
* Defines the target IAM Groups in AWS.

```terraform
resource "aws_iam_group_membership" "education_members" {
  name = "education-group-membership"
  group = aws_iam_group.education.name

  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "Education"
  ]
}
```
* **Dynamic Memberships**: Loops through the created IAM users list and assigns users to groups based on criteria:
  - `Education` Group: Assigned if `user.tags.Department == "Education"`.
  - `Managers` Group: Assigned if `user.tags.Department == "Engneering"` (matching the criteria defined in code).
  - `Engineers` Group: Assigned if their JobTitle tag contains words like `Manager` or `CEO` via regex parsing: `can(regex("Manager|CEO", user.tags.JobTitle))`.

---

## 6. Outputs & CLI Lookups (`output.tf`)

```terraform
output "user_password" {
  value = {
    for user, profile in aws_iam_user_login_profile.users:
    user => profile.password
  }
  sensitive = true
}
```
* Captures and outputs all initial user temporary passwords. Marked as `sensitive = true` to prevent passwords from printing raw in console outputs.

### CLI Passwords Decryption
To view the output passwords cleanly, run:
```bash
terraform output -json user_password
```

### AWS CLI Console Expression Explanation
During debugging or interactive lookup, you can query specific user ARNs using the Terraform console:
```bash
terraform console
```
Then run this command:
```terraform
{ for k, u in aws_iam_user.users : k => u.arn }
```
**Explanation of the line:**
* This is a **For Expression** in Terraform.
* `for k, u in aws_iam_user.users`: Loops through all users maps, where `k` is the user key (e.g. `Michael`) and `u` is the user resource object.
* `k => u.arn`: Returns a map projection containing the user key as key and their generated Amazon Resource Name (ARN) as value.