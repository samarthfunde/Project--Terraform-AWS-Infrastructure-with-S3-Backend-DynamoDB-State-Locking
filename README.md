# 🔐 Terraform AWS Infrastructure with S3 Backend & DynamoDB State Locking

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)

## 📌 Project Purpose
---
The purpose of this project is to implement **Terraform remote state management using AWS S3 and DynamoDB** so that:

- Terraform state is stored centrally in **Amazon S3**
- State changes are protected from conflicts using **DynamoDB state locking**
- Multiple users can work on the same infrastructure **without overwriting each other’s changes**
- Real-world issues like **state lock errors, duplicate resources, and backend reconfiguration** are understood and resolved
- AWS infrastructure (**EC2, Security Group, Key Pair, VPC**) is managed using **Infrastructure as Code (IaC)** following production best practices

👉 **In short:**  
This project simulates how Terraform is used by real DevOps teams with a **remote backend and state locking on AWS**.

---

## 📌 Project Overview
---
This project demonstrates a **production-grade Terraform setup** implementing:

- **Amazon S3** as a remote backend for Terraform state storage  
- **Amazon DynamoDB** for state locking and consistency control  
- **AWS EC2 infrastructure** provisioning along with security groups and key pairs  

This is a **real-world DevOps implementation** that shows how enterprise teams manage Terraform state safely across **multiple engineers** without conflicts or state corruption.


## 🎯 Problem Statement

In collaborative DevOps environments, multiple engineers often work on the same infrastructure code. Without proper state management:

- ❌ Concurrent `terraform apply` runs can **corrupt the state file**
- ❌ Infrastructure changes become **unpredictable and inconsistent**
- ❌ Team collaboration becomes **difficult and error-prone**

### ✅ Solution

This project implements **distributed state locking** using DynamoDB, ensuring:
- Only one user can modify infrastructure at a time
- State file integrity is maintained
- Automatic lock acquisition and release
- Safe collaborative Terraform workflows

---

## 🏗️ Architecture
```
┌─────────────┐
│   Dev Team  │
└──────┬──────┘
       │
       ├──────► Terraform CLI
       │
       ▼
┌──────────────────────────────────┐
│     AWS Cloud Infrastructure     │
│                                  │
│  ┌────────────┐  ┌────────────┐  │
│  │  S3 Bucket │  │  DynamoDB  │  │
│  │   (State)  │  │   (Lock)   │  │
│  └────────────┘  └────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  EC2 + Security Group +    │  │
│  │       Key Pair             │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

---

## 📂 Project Structure
```
HW_Terra_Practice/
│
├── remote-infra/          # One-time infra
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── provider.tf
│   └── terraform.tf
│
├── terraform.tf           # Main infra backend config .. Terraform provider and S3 backend configuration 
├── ec2.tf                 # EC2 instance resource definition
├── variables.tf           # Parameterized input variables
├── outputs.tf             # Output values (IP, instance ID, etc.)
└── README.md

```

## 🛠️ Technologies Used

- **Terraform** - Infrastructure as Code
- **AWS EC2** - Compute instances
- **AWS S3** - Remote state storage
- **AWS DynamoDB** - State locking mechanism
- **AWS IAM** - Access management
- **Git** - Version control
---

## 🔐 Backend Configuration

HW_Terra_Practice/
├── terraform.tf

```hcl
terraform {
  backend "s3" {
    bucket         = "samarth-bucket-16-jan"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "samarth-state-table"
  }
}
```

### 🔒 How State Locking Works

1. **User-1** runs `terraform apply`
   - DynamoDB creates a lock entry
   - State file is locked for exclusive access
   
2. **User-2** attempts `terraform apply` simultaneously
   - Receives lock error (expected behavior)
   - Must wait for User-1 to complete

3. **Lock Release**
   - Automatically released after User-1's operation completes
   - User-2 can now proceed

---

## 👥 Practical Lock Conflict Scenario

### Scenario: Two Engineers Working Simultaneously
```bash
# User-1 (Terminal 1)
$ terraform apply
Acquiring state lock. This may take a few moments...
✅ Lock acquired successfully
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```
```bash
# User-2 (Terminal 2 - at the same time)
$ terraform apply
Acquiring state lock. This may take a few moments...
❌ Error: Error acquiring the state lock

Error message:
  ConditionalCheckFailedException: The conditional request failed
  Lock Info:
    ID:        a1b2c3d4-5678-90ef-ghij-klmnopqrstuv
    Path:      samarth-bucket-16-jan/terraform.tfstate
    Operation: OperationTypeApply
    Who:       user1@hostname
    Created:   2026-01-16 10:30:45.123456 +0000 UTC
```

### ✅ Correct Solution

**User-2 should:**
1. Wait for User-1 to complete their operation
2. Lock will be **automatically released**
3. Retry `terraform apply`

### ❌ Wrong Solution (Dangerous!)
```bash
# ⚠️ DO NOT DO THIS unless absolutely necessary
terraform apply -lock=false
```

**Consequences:**
- State file corruption
- Infrastructure inconsistencies
- Potential resource conflicts
- Production outages

---

## 🚨 Emergency: Stuck Lock Resolution

If Terraform crashed and the lock wasn't released:
```bash
# 1. Verify no one else is running Terraform
# 2. Check DynamoDB table for lock entry
# 3. Force unlock (use with extreme caution)

terraform force-unlock <LOCK_ID>
```

**When to use:**
- ✅ Terraform process crashed unexpectedly
- ✅ Confirmed no one else is running operations
- ❌ Just because you're impatient

---

## 🧪 Common Errors & Solutions

### 1️⃣ Error: Backend configuration changed
```bash
Error: Backend configuration changed
```

**Solution:**
```bash
terraform init -reconfigure
```

### 2️⃣ Error: S3 bucket does not exist
```bash
Error: Failed to get existing workspaces: S3 bucket does not exist
```

**Solution:**
- Create S3 bucket manually first
- Or use a separate Terraform config to create backend resources

### 3️⃣ Error: DynamoDB table does not exist
```bash
Error: Error acquiring the state lock: ResourceNotFoundException
```

**Solution:**
- Create DynamoDB table with:
  - Primary key: `LockID` (String)
  - Billing mode: PAY_PER_REQUEST (recommended)

### 4️⃣ Error: Access Denied
```bash
Error: error configuring S3 Backend: AccessDenied
```

**Solution:**
- Verify IAM permissions for S3 and DynamoDB . Warning: i used (fulladminaccess) but dont use in production fulladminaccess to IAM user
- Required permissions: `s3:GetObject`, `s3:PutObject`, `dynamodb:PutItem`, `dynamodb:GetItem`, `dynamodb:DeleteItem`

---

## 🚀 Getting Started

### Prerequisites

- AWS Account with appropriate IAM permissions
- Terraform installed (v1.0+)
- AWS CLI configured
- S3 bucket created
- DynamoDB table created with `LockID` primary key

### Installation & Execution
```bash
# 1. Clone the repository
git clone https://github.com/samarthfunde/Project--Terraform-AWS-Infrastructure-with-S3-Backend-DynamoDB-State-Locking.git
cd infra-remote

# 2. Initialize Terraform (downloads providers, configures backend)
terraform init

# 3. Review planned changes
terraform plan

# 4. Apply infrastructure changes
terraform apply

# 5. Verify resources in AWS Console

# 6. Destroy resources (when done)
terraform destroy
```

---

## 📋 Best Practices Implemented

- ✅ **Remote State Storage** - S3 for centralized state management
- ✅ **State Locking** - DynamoDB prevents concurrent modifications
- ✅ **Version Control** - `.gitignore` excludes sensitive files
- ✅ **Modular Code** - Separate files for different resources
- ✅ **Documentation** - Comprehensive README and inline comments
- ✅ **Error Handling** - Common issues documented with solutions

---

## 🧠 Key Learnings

- Remote backends are **mandatory** for team environments
- DynamoDB state locking prevents **concurrent execution conflicts**
- Lock acquisition and release are **automatic** in normal operations
- Force unlock should be used **only in emergencies**
- State file security is **critical** for infrastructure safety

---

## 🌐 Real-World Use Cases

This pattern is used in:

- ✅ **Enterprise DevOps Teams** - Multiple engineers collaborating
- ✅ **CI/CD Pipelines** - Jenkins, GitLab CI, GitHub Actions
- ✅ **Multi-Environment Deployments** - Dev, Staging, Production
- ✅ **Infrastructure Compliance** - change tracking

---

## 📚 Additional Resources

- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [DynamoDB State Locking](https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

---

## 👤 Author

**Samarth**

- 🔧 DevOps Engineer
- ☁️ AWS Engineer
---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you understand Terraform state management!

---

## 📞 Contact

For questions or suggestions, feel free to reach out or open an issue!
mail id: samarthf28@gmail.com

---

**Built with ❤️ for the DevOps Community**
