# Terraform Functions Part - 2

## Topics Covered
- [Variable Validation Rules](#variable-validation-rules)
- [Numeric & Math Functions](#numeric--math-functions)
- [Filesystem Functions](#filesystem-functions)
- [Type Conversion Functions](#type-conversion-functions)
- [Date and Time Functions](#date-and-time-functions)
- [Go back to Functions Part 1](#go-back-to-functions-part-1)
- [Hands-on Lab Example](#hands-on-lab-example)

---

## Variable Validation Rules

Validation rules allow you to validate input variables before Terraform creates or modifies resources. They use conditions containing functions like `length()`, `can()`, `regex()`, and string inspection functions like `endswith()`.

### Most Frequently Used Validation Helpers
* **`length(string/list)`**: Evaluates the character count of a string or number of items in a collection.
* **`can(expression)`**: Returns `true` if the expression runs without errors, and `false` if it fails.
* **`regex(pattern, string)`**: Searches for a matching pattern in a string.
* **`endswith(string, suffix)`**: Returns `true` if the string ends with the specified suffix.

### Practical Lab Example:
From our [`lab/variables.tf`](./lab/variables.tf):
```terraform
variable "instance_type" {
  default = "t2.micro"

  # Enforce length constraints
  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "instance type must be between 2 and 20 characters"
  }

  # Enforce naming pattern (must start with t2. or t3.)
  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "instance type must be t2 or t3"
  }
}

variable "backup_name" {
  default = "daily_backup"

  # Enforce suffix convention
  validation {
    condition     = endswith(var.backup_name, "_backup")
    error_message = "Backup name must end with _backup"
  }
}
```

---

## Numeric & Math Functions

Numeric functions perform calculations, boundary checking, and mathematical updates.

### Most Frequently Used Numeric Functions
* **`abs(number)`**: Returns the absolute (positive) value of a number.
  ```terraform
  abs(-50)       # Output: 50
  ```
* **`max(numbers...)`**: Compares and returns the largest value.
  ```terraform
  max(50, 100, 75, 200) # Output: 200
  ```
* **`min(numbers...)`**: Compares and returns the smallest value.
  ```terraform
  min(50, 100, 75, 200) # Output: 50
  ```
* **`sum(list)`**: Adds up all numbers in a list.
  ```terraform
  sum([50, 100, 75])    # Output: 225
  ```

### Practical Lab Example:
From our [`lab/main.tf`](./lab/main.tf):
```terraform
locals {
  # Converts negative monthly costs to positive numbers: [-50, 100...] -> [50, 100...]
  positive_cost = [for cost in var.monthly_cost : abs(cost)]

  # Finds maximum and minimum costs (using expansion operator ...)
  max_cost      = max(local.positive_cost...)
  min_cost      = min(local.positive_cost...)

  # Sums the entire list of positive costs
  total_cost    = sum(local.positive_cost)

  # Calculates average cost using division and length
  avg_const     = local.total_cost / length(local.positive_cost)
}
```

---

## Filesystem Functions

Filesystem functions are used to read and check the existence of local files on disk.

### Most Frequently Used Filesystem Functions
* **`file(path)`**: Reads the contents of a local file at the specified path and returns them as a raw text string.
  ```terraform
  file("${path.module}/userdata.sh") # Output: string contents of userdata.sh
  ```
* **`fileexists(path)`**: Determines if a file exists at the given path (returns `true` or `false`).
  ```terraform
  fileexists("${path.module}/config.json") # Output: true or false
  ```

---

## Type Conversion Functions

Type conversion functions convert values between data types or safely check variables.

### Most Frequently Used Type Conversion Functions
* **`tostring(value)`**: Converts a given value to a string.
  ```terraform
  tostring(10) # Output: "10"
  ```
* **`tonumber(value)`**: Converts a numeric string to a number.
  ```terraform
  tonumber("20") # Output: 20
  ```
* **`tobool(value)`**: Converts a string to a boolean.
  ```terraform
  tobool("true") # Output: true
  ```
* **`toset(value)`**: Converts a list to a set, automatically removing duplicate values.
  ```terraform
  toset(["us-east-1", "us-west-2", "us-east-1"]) # Output: ["us-east-1", "us-west-2"]
  ```

### Practical Lab Example:
From our [`lab/main.tf`](./lab/main.tf):
```terraform
locals {
  # Concatenates user and default location lists
  all_locations       = concat(var.user_location, var.default_locations)

  # Converts the combined list to a set to remove duplicates
  all_unique_location = toset(local.all_locations)
}
```

---

## Date and Time Functions

Date and time functions retrieve the current system time and format timestamps.

### Most Frequently Used Date and Time Functions
* **`timestamp()`**: Returns the current UTC date and time in RFC 3339 format.
  ```terraform
  timestamp() # Output: "2026-07-28T12:00:00Z" (example)
  ```
* **`formatdate(spec, timestamp)`**: Formats a timestamp string into a customized date format.
  ```terraform
  formatdate("YYYY-MM-DD", timestamp()) # Output: "2026-07-28"
  ```
* **`timeadd(timestamp, duration)`**: Adds a duration (e.g., `"10m"`, `"24h"`) to a timestamp and returns the new timestamp.
  ```terraform
  timeadd(timestamp(), "24h") # Output: timestamp 24 hours in the future
  ```

---

## Go back to Functions Part 1

For basic functions, case manipulation, and collection functions, see Part 1 of this guide:

* **[Terraform Functions Part - 1 (String, Collection, lookup)](../011%20-%20Functions%20in%20Terraform%20Part%201/011-function-in-terraform-part-1.md)**

---

## Hands-on Lab Example

All functions and validation rules demonstrated in this guide are implemented in the [`lab`](./lab/) directory:

- [`variables.tf`](./lab/variables.tf) — Declarations with custom validation rules using `length()`, `can()`, `regex()`, and `endswith()`.
- [`main.tf`](./lab/main.tf) — Lab logic using numeric math operations (`abs`, `max`, `min`, `sum`) and list conversions (`concat`, `toset`).
- [`output.tf`](./lab/output.tf) — Outputs for validating formatted costs, locations, and rules.

### Commands to Run:
```bash
# Navigate to the lab folder
cd "docs/Module - 2 AWS resources using Terraform/012 - Functions in Terraform Part 2/lab"

# Initialize
terraform init

# Validate configuration and variables rules
terraform validate

# Inspect values using the console
terraform console

# Preview outputs and plan
terraform plan
```