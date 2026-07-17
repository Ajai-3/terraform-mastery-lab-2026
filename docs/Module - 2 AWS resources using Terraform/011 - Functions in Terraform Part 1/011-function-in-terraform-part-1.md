# Terraform Functions Part - 1

## Topics Covered
- [What is a Function?](#what-is-a-function)
- [What is a Terraform Function?](#what-is-a-terraform-function)
- [Types of Terraform Functions](#types-of-terraform-functions)
  - [String Functions](#string-functions)
  - [Numeric Functions](#numeric-functions)
  - [Collection Functions](#collection-functions)
  - [Filesystem Functions](#filesystem-functions)
  - [Type Conversion Functions](#type-conversion-functions)
  - [Date and Time Functions](#date-and-time-functions)
- [Hands-on Lab Example](#hands-on-lab-example)

---

## What is a Function?

A function is a self-contained, reusable block of code designed to perform a specific task.

**Example**:
Finding the sum of two numbers — we pass two numbers to the function, and the function does the math and returns the sum.

---

## What is a Terraform Function?

In Terraform, we use HCL (HashiCorp Configuration Language). It is a configuration language, not a full general-purpose programming language.

Unlike general-purpose programming languages (like Python or Java) that support Object-Oriented Programming (OOP), custom classes, and arbitrary custom logic, HCL is designed specifically to declare infrastructure state. While it includes programming-like features (such as variables, conditionals, loops, and built-in functions), it is intentionally structured and restricted to focus on safety, readability, and state management.

In Terraform, there is no such thing as a "Custom Function". You can only use the built-in functions provided by Terraform Core; you cannot write your own custom functions.

To test built-in functions interactively, you can run:
```bash
terraform console
```

---

## Types of Terraform Functions

![Types of Terraform Functions](./images/terraform-function-types.png)

---

### String Functions

String functions are built-in tools used to format, combine, replace, split, and manipulate text strings.

#### Most Frequently Used String Functions

##### 1. Case Manipulation
* **`lower(string)`**: Converts all letters in a string to lowercase.
  ```terraform
  lower("PROD-SERVER")  # Output: "prod-server"
  ```
* **`upper(string)`**: Converts all letters in a string to uppercase.
  ```terraform
  upper("dev")          # Output: "DEV"
  ```
* **`title(string)`**: Capitalizes the first letter of each word.
  ```terraform
  title("web server")   # Output: "Web Server"
  ```

##### 2. Joining & Splitting Text
* **`join(separator, list)`**: Concatenates a list of strings into a single string using a delimiter.
  ```terraform
  join("-", ["app", "dev", "us-east-1"])  # Output: "app-dev-us-east-1"
  ```
* **`split(separator, string)`**: Splits a single string into a list of strings based on a delimiter.
  ```terraform
  split(",", "web,db,cache")            # Output: ["web", "db", "cache"]
  ```

##### 3. Replacing & Trimming
* **`replace(string, substring, replacement)`**: Replaces occurrences of a specific character or pattern.
  ```terraform
  replace("10.0.0.0/16", "/", "-")      # Output: "10.0.0.0-16"
  ```
* **`trimspace(string)`**: Removes leading and trailing whitespaces and newlines.
  ```terraform
  trimspace("  my-server-id  ")         # Output: "my-server-id"
  ```

##### 4. String Inspection & Formatting
* **`format(spec, values...)`**: Formats a string using C-style printf rules (great for padding numbers).
  ```terraform
  format("web-server-%02d", 3)          # Output: "web-server-03"
  ```
* **`substr(string, offset, length)`**: Extracts a substring starting at a specific index.
  ```terraform
  substr("ami-0c7217cdde317cfec", 0, 7) # Output: "ami-0c7"
  ```

#### Practical Lab Example:
From our [`lab/main.tf`](./lab/main.tf):
```terraform
locals {
  # Converts "Project XYZ Resource" to "project-xyz-resource"
  formatted_project_name = lower(replace(var.project_name, " ", "-"))

  # Truncates, converts to lowercase, and removes spaces/special characters
  # Converts "project alfa bucket with CAPS and spaces!!!" to "projectalfabucketwithcapsandspaces"
  formatted_bucket_name = replace(replace(
    substr(lower(var.bucket_name), 3, 63), " ", ""
  ), "!", "")

  # Cleans and splits "80, 443, 8080, 3306" into ["80", "443", "8080", "3306"]
  port_list = split(",", replace(var.allowed_ports, " ", ""))
}

resource "aws_s3_bucket" "name" {
  bucket = local.formatted_bucket_name
}
```

---

### Numeric Functions

Numeric functions in Terraform are built-in tools used to perform mathematical operations, calculations, rounding, and limits on integers and floats.

#### Most Frequently Used Numeric Functions

##### 1. Basic Math & Absolute Values
* **`abs(number)`**: Returns the absolute (positive) value of a given number.
  ```terraform
  abs(-15)       # Output: 15
  abs(15)        # Output: 15
  ```

##### 2. Rounding Functions
* **`ceil(number)`**: Rounds a number up to the nearest whole integer.
  ```terraform
  ceil(4.1)      # Output: 5
  ceil(4.9)      # Output: 5
  ```
* **`floor(number)`**: Rounds a number down to the nearest whole integer.
  ```terraform
  floor(4.9)     # Output: 4
  floor(4.1)     # Output: 4
  ```

##### 3. Min & Max (Boundary Limits)
* **`max(numbers...)`**: Compares two or more numbers and returns the largest value.
  ```terraform
  max(5, 12, 9)  # Output: 12
  ```
* **`min(numbers...)`**: Compares two or more numbers and returns the smallest value.
  ```terraform
  min(5, 12, 9)  # Output: 5
  ```

##### 4. Advanced Math Operations
* **`pow(base, exponent)`**: Calculates the power of a base number raised to an exponent.
  ```terraform
  pow(2, 3)      # Output: 8 (2^3)
  pow(10, 2)     # Output: 100
  ```
* **`log(number, base)`**: Calculates the logarithm of a number for a given base.
  ```terraform
  log(100, 10)   # Output: 2
  ```
* **`signum(number)`**: Determines the sign of a number (returns -1 for negative, 0 for zero, 1 for positive).
  ```terraform
  signum(-42)    # Output: -1
  signum(0)      # Output: 0
  signum(42)     # Output: 1
  ```

#### Practical Example:
If you need to calculate disk size based on predicted workload with a buffer factor:
```terraform
locals {
  estimated_gb = 10.4
  
  # Safely rounds up to allocate whole gigabytes (11 GB)
  allocated_disk_size = ceil(local.estimated_gb)
}
```

---

### Collection Functions

Collection functions are built-in tools used to inspect, manipulate, combine, transform, and extract data from collections—such as lists, maps, sets, and objects.

#### Most Frequently Used Collection Functions

##### 1. Element & Lookup Operations
* **`lookup(map, key, default)`**: Retrieves the value of a single key from a map. If the key doesn't exist, it returns a default value instead of throwing an error.
  ```terraform
  lookup({ env = "dev" }, "env", "prod")    # Output: "dev"
  lookup({ env = "dev" }, "owner", "admin") # Output: "admin" (default fallback)
  ```
* **`element(list, index)`**: Retrieves a single element from a list at the given index. If the index is out of bounds, it wraps around.
  ```terraform
  element(["us-east-1a", "us-east-1b"], 0)  # Output: "us-east-1a"
  element(["us-east-1a", "us-east-1b"], 2)  # Output: "us-east-1a" (wraps around!)
  ```

##### 2. Size & Checking
* **`length(collection)`**: Returns the total number of elements in a list, map, set, or characters in a string.
  ```terraform
  length(["subnet1", "subnet2", "subnet3"]) # Output: 3
  ```
* **`contains(list, value)`**: Checks if a given value exists inside a list (returns true or false).
  ```terraform
  contains(["dev", "stage", "prod"], "dev") # Output: true
  ```

##### 3. Combining & Merging Collections
* **`merge(maps...)`**: Combines multiple maps into a single map. If keys overlap, the right-most map's value overrides the previous ones.
  ```terraform
  merge({ env = "dev" }, { owner = "ops" }) 
  # Output: { "env" = "dev", "owner" = "ops" }
  ```
* **`concat(lists...)`**: Joins two or more lists into a single combined list.
  ```terraform
  concat(["a", "b"], ["c", "d"]) 
  # Output: ["a", "b", "c", "d"]
  ```

##### 4. Cleaning & Flattening
* **`flatten(list)`**: Replaces nested lists with a single flat list.
  ```terraform
  flatten([["a", "b"], ["c", "d"]]) 
  # Output: ["a", "b", "c", "d"]
  ```
* **`compact(list)`**: Removes all empty strings ("") or null values from a list of strings.
  ```terraform
  compact(["web", "", "db", null]) 
  # Output: ["web", "db"]
  ```
* **`distinct(list)`**: Removes all duplicate values from a list.
  ```terraform
  distinct(["dev", "prod", "dev", "test"]) 
  # Output: ["dev", "prod", "test"]
  ```

#### Practical Lab Example:
From our [`lab/main.tf`](./lab/main.tf):
```terraform
locals {
  # Merges default tags and environment tags together
  new_tag = merge(var.default_tags, var.environment_tags)

  # Looks up environment instance size (defaults to "t2.micro" if not found)
  instance_size = lookup(var.instance_size, var.environment, "t2.micro")
}

resource "aws_s3_bucket" "name" {
  bucket = local.formatted_bucket_name
  tags   = local.new_tag
}
```

---

### Filesystem Functions

Filesystem functions are used to read and interact with local files on disk.

#### Most Frequently Used Filesystem Functions

* **`file(path)`**: Reads the contents of a local file at the specified path and returns them as a raw text string.
  ```terraform
  file("${path.module}/userdata.sh") # Output: string contents of userdata.sh
  ```
* **`fileexists(path)`**: Determines if a file exists at the given path (returns `true` or `false`).
  ```terraform
  fileexists("${path.module}/config.json") # Output: true or false
  ```

#### Practical Example:
```terraform
resource "aws_instance" "web" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t3.micro"

  # Reads user_data script dynamically from a local file
  user_data = file("${path.module}/scripts/setup.sh")
}
```

---

### Type Conversion Functions

Type conversion functions allow you to transform values from one data type to another or test expressions safely.

#### Most Frequently Used Type Conversion Functions

* **`tostring(value)`**: Converts a given value to a string.
  ```terraform
  tostring(10) # Output: "10"
  ```
* **`tonumber(value)`**: Converts a string containing a number to a numeric value.
  ```terraform
  tonumber("20") # Output: 20
  ```
* **`tobool(value)`**: Converts a string ("true" or "false") to a boolean value.
  ```terraform
  tobool("true") # Output: true
  ```
* **`tolist(value)`**: Converts a set or other collection type to a list.
  ```terraform
  tolist(var.unique_set)
  ```
* **`toset(value)`**: Converts a list to a set, automatically removing any duplicate items.
  ```terraform
  toset(["dev", "prod", "dev"]) # Output: ["dev", "prod"]
  ```
* **`can(expression)`**: Evaluates an expression and returns `true` if it succeeds, or `false` if it fails with an error. Useful for custom type checks.
  ```terraform
  can(regex("^[a-z]+$", var.env_name))
  ```
* **`try(expressions...)`**: Evaluates a list of expressions in order and returns the value of the first one that does not throw an error.
  ```terraform
  try(var.config.ami, "ami-0c7217cdde317cfec") # Fallback to default AMI if config.ami errors
  ```

#### Practical Example:
```terraform
variable "environment_input" {
  type    = string
  default = "DEV"
}

locals {
  # Force input string to lowercase and convert it to a set for unique items
  unique_envs = toset([lower(var.environment_input), "prod"])
}
```

---

### Date and Time Functions

Date and time functions are used to retrieve the current time and format dates.

#### Most Frequently Used Date and Time Functions

* **`timestamp()`**: Returns the current UTC date and time in RFC 3339 format.
  ```terraform
  timestamp() # Output: "2026-07-25T06:00:00Z" (example)
  ```
* **`formatdate(spec, timestamp)`**: Formats a timestamp string into a customized date format.
  ```terraform
  formatdate("YYYY-MM-DD", timestamp()) # Output: "2026-07-25"
  ```
* **`timeadd(timestamp, duration)`**: Adds a duration (e.g., `"10m"`, `"24h"`) to a timestamp and returns the new timestamp.
  ```terraform
  timeadd(timestamp(), "24h") # Output: timestamp 24 hours in the future
  ```

#### Practical Example:
```terraform
resource "aws_s3_bucket" "log_bucket" {
  bucket = "app-logs-bucket"

  tags = {
    # Dynamically sets tag to the date of creation: e.g. "2026-07-25"
    CreatedOn   = formatdate("YYYY-MM-DD", timestamp())
    ManagedBy   = "Terraform"
  }
}
```

---

## Hands-on Lab Example

All functions demonstrated in this guide are implemented in the [`lab`](./lab/) directory:

- [`variables.tf`](./lab/variables.tf) — Declarations for project names, allowed ports, and environment-based sizes.
- [`main.tf`](./lab/main.tf) — Main lab logic using string and collection functions.
- [`output.tf`](./lab/output.tf) — Outputs for formatting inspection.

### Commands to Run:
```bash
# Navigate to the lab folder
cd "docs/Module - 2 AWS resources using Terraform/011 - Functions in Terraform Part 1/lab"

# Initialize
terraform init

# Validate configuration
terraform validate

# Inspect values using the console
terraform console

# Preview outputs and plan
terraform plan
```

