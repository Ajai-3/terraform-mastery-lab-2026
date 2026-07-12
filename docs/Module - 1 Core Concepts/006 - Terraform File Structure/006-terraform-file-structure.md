# Terraform File Structure

## Topics Covered
- [Terraform File Organization](#terraform-file-organization)
- [Sequence of File Loading](#sequence-of-file-loading)
- [Best Practices for Structure](#best-practices-for-structure)
- [Environment Separation with tfvars](#environment-separation-with-tfvars)

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

## Best Practices for Structure

- **Separate variables and outputs** into `variables.tf` and `output.tf` for readability.
- **Isolate your backend configuration** in a dedicated `backend.tf` file.
- **Always use a `.gitignore`** to ensure local state and `.terraform/` caches are not pushed to GitHub.

---

## Environment Separation with `.tfvars`

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