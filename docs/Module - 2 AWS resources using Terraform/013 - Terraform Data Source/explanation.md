# Terraform Data Source - Code Explanation

This document provides a line-by-line explanation of the code inside [`lab/main.tf`](./lab/main.tf).

---

## 1. Querying the VPC Data Source

```terraform
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}
```

* **`data "aws_vpc" "vpc"`**:
  - `data`: Declares a read-only data source block to query existing AWS infrastructure.
  - `"aws_vpc"`: The type of data source (provided by the AWS provider).
  - `"vpc"`: The local name used to reference this block's attributes elsewhere in our code (e.g. `data.aws_vpc.vpc.id`).
* **`filter { ... }`**:
  - Defines query criteria to narrow down search results.
* **`name = "tag:Name"`**:
  - Tells Terraform to look up the VPC by its Name tag.
* **`values = ["default"]`**:
  - Specifies that the Name tag of the VPC must be `"default"`.

---

## 2. Querying Subnet 1 Data Source

```terraform
data "aws_subnet" "subnet_1" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["subnet_1"]
  }
}
```

* **`data "aws_subnet" "subnet_1"`**:
  - Declares a subnet data source and names it `"subnet_1"`.
* **`vpc_id = data.aws_vpc.vpc.id`**:
  - Restricts the search to only subnets belonging to the VPC queried in the previous block (`data.aws_vpc.vpc.id`).
* **`filter { name = "tag:Name" values = ["subnet_1"] }`**:
  - Finds the subnet within that VPC whose Name tag is exactly `"subnet_1"`.

---

## 3. Querying Subnet 2 Data Source

```terraform
data "aws_subnet" "subnet_2" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["subnet_2"]
  }
}
```

* **`data "aws_subnet" "subnet_2"`**:
  - Declares another subnet data source and names it `"subnet_2"`.
* **`vpc_id = data.aws_vpc.vpc.id`**:
  - Restricts the query to the same default VPC.
* **`filter { name = "tag:Name" values = ["subnet_2"] }`**:
  - Finds the subnet whose Name tag is exactly `"subnet_2"`.

---

## 4. Querying the Linux AMI Data Source

```terraform
data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

* **`data "aws_ami" "linux2"`**:
  - Declares an AMI data source block and names it `"linux2"`.
* **`owners = ["amazon"]`**:
  - Restricts the search to official Amazon-owned images to avoid downloading unverified community AMIs.
* **`most_recent = true`**:
  - Ensures Terraform returns only the latest version matching the filters.
* **`filter { name = "name" values = ["amzn2-ami-hvm-*-x86_64-gp2"] }`**:
  - Filters by image name prefix matching Amazon Linux 2 (`amzn2-ami-hvm-*-x86_64-gp2`), using `*` as a wildcard for date releases.
* **`filter { name = "virtualization-type" values = ["hvm"] }`**:
  - Filters by virtualization type to ensure compatibility (`hvm`).

---

## 5. Launching EC2 Instances in Subnet 1

```terraform
resource "aws_instance" "subnet_1_instance" {
  count         = 2
  ami           = data.aws_ami.linux2.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.subnet_1.id

  tags = {
    Name = "Subnet_1_Instance-${count.index + 1}"
  }
}
```

* **`resource "aws_instance" "subnet_1_instance"`**:
  - Declares a resource block to deploy an EC2 instance.
* **`count = 2`**:
  - Deploys exactly 2 identical EC2 instances.
* **`ami = data.aws_ami.linux2.id`**:
  - Dynamically injects the AMI ID fetched by the AMI data source (`data.aws_ami.linux2.id`).
* **`instance_type = var.instance_type`**:
  - Uses the instance type defined in our variables (`t3.micro`).
* **`subnet_id = data.aws_subnet.subnet_1.id`**:
  - Places the EC2 instances directly into the subnet ID fetched by the Subnet 1 data source.
* **`tags = { Name = "Subnet_1_Instance-${count.index + 1}" }`**:
  - Labels the instances dynamically: `"Subnet_1_Instance-1"` and `"Subnet_1_Instance-2"`.

---

## 6. Launching EC2 Instances in Subnet 2

```terraform
resource "aws_instance" "subnet_2_instance" {
  count         = 2
  ami           = data.aws_ami.linux2.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.subnet_2.id

  tags = {
    Name = "Subnet_2_Instance-${count.index + 1}"
  }
}
```

* **`resource "aws_instance" "subnet_2_instance"`**:
  - Declares a resource block to deploy EC2 instances in the second subnet.
* **`count = 2`**:
  - Deploys 2 instances in Subnet 2.
* **`subnet_id = data.aws_subnet.subnet_2.id`**:
  - Uses the subnet ID fetched by the Subnet 2 data source.
* **`tags = { Name = "Subnet_2_Instance-${count.index + 1}" }`**:
  - Labels the instances dynamically: `"Subnet_2_Instance-1"` and `"Subnet_2_Instance-2"`.
