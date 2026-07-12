# Terraform File Structure

## Topics Covered
- [Terraform File Organization](#terraform-file-organization)
- [Sequence of File Loading](#sequence-of-file-loading)
- [Environment Separation with tfvars](#environment-separation-with-tfvars)
- [Advanced File Organization Patterns](#advanced-file-organization-patterns)
- [Best Practices for Structure](#best-practices-for-structure)
- [Commands for Testing](#commands-for-testing)
- [Common File Organization Mistakes](#common-file-organization-mistakes)

---

## Terraform File Organization

There is no strict rule or format you must stick to. Below is a standard, recommended style that is commonly used:

```text
terraform-project/

main.tf                     // All resource definitions
variables.tf                // Declare all input variables
output.tf                   // Define what information to display after `terraform apply`
versions.tf                 // Lock Terraform and provider versions for consistency
backend.tf                  // Configure cloud provider settings
terraform.tfvars            // Actual variable values for your environment (Don't push to Git)
terraform.tfvars.example    // Template showing what variables need values (Can be pushed to GitHub)
.gitignore                  
README.md
```

---

## Sequence of File Loading

- Terraform loads **all** files ending with `.tf` in the current working directory.
- It merges them together in memory, meaning file names do not affect how resources are ordered or executed.
- You cannot define duplicate resource names, variables, or local values across different files.

---

## Environment Separation with tfvars

If you hardcode default values into `variables.tf`, you have to modify your code every time you switch between `dev`, `stage`, and `prod`.

Instead, you write your `.tf` code once and keep separate `.tfvars` files:

### `dev.tfvars`
```terraform
Environment = "dev"
vpc_cidr    = "10.0.0.0/16"
```

### `prod.tfvars`
```terraform
Environment = "prod"
vpc_cidr    = "10.200.0.0/16"
```

When deploying, you simply pass the file you want without touching your core code:

```powershell
terraform apply -var-file="prod.tfvars"
```

---

## Advanced File Organization Patterns

### Environment-Specific Structure
```text
environments/
├── dev/
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── main.tf
├── staging/
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── main.tf
└── production/
    ├── backend.tf
    ├── terraform.tfvars
    └── main.tf

modules/
├── vpc/
├── security/
└── compute/

shared/
├── variables.tf
├── outputs.tf
└── locals.tf
```

### Service-Based Structure
```text
infrastructure/
├── networking/
│   ├── vpc.tf
│   ├── subnets.tf
│   └── routing.tf
├── security/
│   ├── security-groups.tf
│   ├── nacls.tf
│   └── iam.tf
├── compute/
│   ├── ec2.tf
│   ├── autoscaling.tf
│   └── load-balancers.tf
├── storage/
│   ├── s3.tf
│   ├── ebs.tf
│   └── efs.tf
└── data/
    ├── rds.tf
    ├── dynamodb.tf
    └── elasticache.tf
```

---

## Best Practices for Structure

- **Consistent Naming**:
  - Use clear, descriptive file names.
  - Follow team conventions.
  - Use lowercase with hyphens or underscores.
- **Logical Grouping**:
  - Group related resources together.
  - Separate by AWS service or function.
  - Consider dependencies when organizing.
- **Size Management**:
  - Keep files manageable (< 500 lines).
  - Split large files by functionality.
  - Use modules for reusable components.
- **Dependencies**:
  - Place provider and backend configs first.
  - Define variables before using them.
  - Output values at the end.
- **Documentation**:
  - Include a `README.md` file.
  - Comment complex configurations.
  - Document the purpose of variables.

---

## Commands for Testing

Use these commands to validate, format, and test your file structure:

- **Validate the reorganized structure**:
  ```bash
  terraform validate
  ```
- **Format all files consistently**:
  ```bash
  terraform fmt -recursive
  ```
- **Plan to ensure no unexpected changes**:
  ```bash
  terraform plan
  ```
- **Apply if everything looks good**:
  ```bash
  terraform apply
  ```

---

## Common File Organization Mistakes

- **Everything in `main.tf`**: Makes the code hard to navigate and edit.
- **Inconsistent Naming**: Confuses team members and breaks conventions.
- **Mixed Concerns**: Placing resources together that don't belong together.
- **No Documentation**: Difficult for others (and your future self) to understand.
- **Overly Complex Structure**: Simple is often better; do not over-engineer the directory layout too early.