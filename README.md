# <img src="https://cdn.simpleicons.org/terraform/7B42BC" width="40" height="40" /> Terraform - Complete Documentation

This documentation covers everything you need to know about Terraform. While it is mostly known for setting up cloud infrastructure, it is a powerful tool that automatically handles the creation, modification, and management of your digital resources. After reading this, you will fully understand how to use it to build and manage your infrastructure reliably and efficiently.

This documentation will help you master Terraform. It mainly focuses on using Terraform with AWS. If you master this, you can apply your knowledge to any cloud provider. Please read the prerequisites before starting.

---

## Prerequisites

- **AWS free account or subscription** - [AWS Free Tier](https://aws.amazon.com/free/)
- **AWS Fundamentals**
- **OSI model and protocols** - SSH, HTTP, HTTPS, TCP, UDP, SMTP, etc.
- **Visual Studio Code** or your preferred IDE installed
- **Git** installed and a working knowledge of Git and GitHub
- **Linux, Mac, or WSL (Windows Subsystem for Linux)**
- **Linux and Shell scripting**
- **Basic understanding of YAML and JSON**
- **Deployment Strategies**
- **Networking Fundamentals**
- **IP Addressing**

---

## 🎓 Learning Path

- **Structured Progression**: Read each document in the proper order and run the examples.
- **Daily Discipline**: Study one document per day to build consistent learning habits.
- **Ultimate Goal**: Complete the 30-day path to gain a deep understanding and master Terraform.

---

## 🛠️ Mini Projects Highlights

Key hands-on mini projects built and deployed using Terraform:

| Mini Project | Description | Link |
| :--- | :--- | :--- |
| **Mini Project 1** | Static Website Hosting on AWS S3 with Bucket Policies | [Static Website Hosting](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/014%20-%20Static%20Website%20Hosting%20%28Mini%20Project%201%29/014-static-website-hosting.md) |
| **Mini Project 2** | AWS VPC Setup and Cross-Region VPC Peering | [VPC and Peering](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/015%20-%20VPC%20and%20Peering%20%28Mini%20Project%202%29/015-vpc-and-peering.md) |
| **Mini Project 3** | AWS IAM User Management using `csvdecode()` | [AWS IAM User Management](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/016%20-%20AWS%20IAM%20User%20Management%20%28Mini%20Project%203%29/016-aws-iam-user-management.md) |
| **Mini Project 4** | AWS Elastic Beanstalk Blue-Green Deployment Demo | [Elastic Beanstalk Blue-Green](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/017%20-%20AWS%20Elastic%20Beanstalk%20Blue-Green%20Deployment%20Demo%20%28Mini%20Project%204%29/017-aws-elastic-beanstalk-blue-green-deployment.md) |

---

## Modules

### Module 1: Core Concepts

- [001 - Introduction](./docs/Module%20-%201%20Core%20Concepts/001%20-%20Introduction/001-Introduction.md)
- [002 - Providers](./docs/Module%20-%201%20Core%20Concepts/002%20-%20Providers/002-Providers.md)
- [003 - S3 Bucket](./docs/Module%20-%201%20Core%20Concepts/003%20-%20S3%20Bucket/003-S3-Bucket.md)
- [004 - State File Management (Remote Backend)](./docs/Module%20-%201%20Core%20Concepts/004%20-%20State%20file%20management%20-%20Remote%20Backend/004-State-file-management-Remote-Backend.md)
- [005 - Terraform Variables](./docs/Module%20-%201%20Core%20Concepts/005%20-%20Terraform%20variables/005-terraform-variables.md)
- [006 - Terraform File Structure](./docs/Module%20-%201%20Core%20Concepts/006%20-%20Terraform%20File%20Structure/006-terraform-file-structure.md)
- [007 - Type Constraints in Terraform](./docs/Module%20-%201%20Core%20Concepts/007%20-%20Type%20Constraints%20in%20Terraform/007-type-constraints-in-terraform.md)
- [008 - Terraform Meta-Arguments](./docs/Module%20-%201%20Core%20Concepts/008%20-%20Terraform%20Meta-Arguments/008-terraform-meta-arguments.md)
- [009 - Terraform Lifecycle Meta-arguments](./docs/Module%20-%201%20Core%20Concepts/009%20-%20Terraform%20Lifecycle%20Meta-arguments/009-terraform-lifecycle-meta-arguments.md)
- [010 - Dynamic Blocks and Expressions](./docs/Module%20-%201%20Core%20Concepts/010%20-%20Dynamic%20Blocks%20and%20expressions/010-dynamic-block-and-expressions.md)

### Module 2: AWS Resources using Terraform

- [011 - Functions in Terraform Part 1](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/011%20-%20Functions%20in%20Terraform%20Part%201/011-function-in-terraform-part-1.md)
- [012 - Functions in Terraform Part 2](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/012%20-%20Functions%20in%20Terraform%20Part%202/012-function-in-terraform-part-2.md)
- [013 - Terraform Data Source](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/013%20-%20Terraform%20Data%20Source/013-terraform-data-source.md)
- [014 - Static Website Hosting (Mini Project 1) 🚀](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/014%20-%20Static%20Website%20Hosting%20%28Mini%20Project%201%29/014-static-website-hosting.md)
- [015 - VPC and Peering (Mini Project 2) 🚀](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/015%20-%20VPC%20and%20Peering%20%28Mini%20Project%202%29/015-vpc-and-peering.md)
- [016 - AWS IAM User Management (Mini Project 3) 🚀](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/016%20-%20AWS%20IAM%20User%20Management%20%28Mini%20Project%203%29/016-aws-iam-user-management.md)
- [017 - AWS Elastic Beanstalk Blue-Green Deployment Demo (Mini Project 4) 🚀](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/017%20-%20AWS%20Elastic%20Beanstalk%20Blue-Green%20Deployment%20Demo%20%28Mini%20Project%204%29/017-aws-elastic-beanstalk-blue-green-deployment.md)
- [018 - Simple Image Processor - Backend Only (Mini Project 5)](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/018%20-%20Simple%20Image%20Processor%20-%20Backend%20Only%20%28Mini%20Project%205%29/018-simple-image-processor.md)
- [019 - Terraform Provisioners Demo (Mini Project 6)](./docs/Module%20-%202%20AWS%20resources%20using%20Terraform/019%20-%20Terraform%20Provisioners%20Demo%20%28Mini%20Project%206%29/019-terraform-provisioners-demo.md)

### Module 3: Advanced Concepts

*(Module 3 contents will be added here)*

---

## 🎨 Architecture & Study Diagrams

All interactive architectural drawings, flowcharts, and study diagrams created during these project labs are hosted on Eraser.io:

👉 **[Eraser.io Architecture & Study Diagrams Workspace](https://app.eraser.io/workspace/IORsUSMRcg0U12ahA6Jf?origin=share)**

---

## Resources Used

- [Eraser.io Architecture & Study Diagrams](https://app.eraser.io/workspace/IORsUSMRcg0U12ahA6Jf?origin=share)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Documentation](http://docs.aws.amazon.com/)