# CSYE6225 – Assignment 3
## Multi-Cloud Infrastructure as Code (AWS + GCP)

This repository contains Terraform configurations to provision networking infrastructure in both AWS and Google Cloud Platform (GCP). The infrastructure is fully parameterized and supports multiple deployments within the same account using unique naming suffixes.

------------------------------------------------------------
REPOSITORY STRUCTURE
------------------------------------------------------------

tf-infra/
│
├── README.md
├── .gitignore
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── terraform.tfvars.example
│
└── gcp/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    └── terraform.tfvars.example

Each cloud provider has isolated Terraform configurations.

------------------------------------------------------------
PREREQUISITES
------------------------------------------------------------

1. Terraform
   terraform --version

2. AWS CLI
   Do NOT use default profile.

   aws configure --profile dev
   aws configure --profile demo

   Verify:
   aws configure list --profile dev
   aws configure list --profile demo

3. Google Cloud CLI

   gcloud config configurations create dev
   gcloud config configurations create demo

   Set project:
   gcloud config set project <project-id>

   Set region and zone:
   gcloud config set compute/region us-east1
   gcloud config set compute/zone us-east1-b

   Authenticate:
   gcloud auth login
   gcloud auth application-default login

------------------------------------------------------------
AWS INFRASTRUCTURE
------------------------------------------------------------

Resources Provisioned:

• 1 VPC
• 3 Public Subnets (3 Availability Zones)
• 3 Private Subnets (3 Availability Zones)
• Internet Gateway attached to VPC
• Public Route Table with:
      0.0.0.0/0 → Internet Gateway
• Private Route Table
• Route Table Associations

All resource names are parameterized using:
<env>-<name_suffix>

------------------------------------------------------------
AWS DEPLOYMENT STEPS
------------------------------------------------------------

cd aws

terraform init
terraform validate

terraform plan \
  -var="aws_profile=demo" \
  -var="env=demo" \
  -var="name_suffix=v1"

terraform apply \
  -var="aws_profile=demo" \
  -var="env=demo" \
  -var="name_suffix=v1"

Destroy if needed:

terraform destroy \
  -var="aws_profile=demo" \
  -var="env=demo" \
  -var="name_suffix=v1"

------------------------------------------------------------
GCP INFRASTRUCTURE
------------------------------------------------------------

Resources Provisioned:

• 1 VPC Network (custom subnet mode)
• 3 Public Subnets (3 zones in same region)
• 3 Private Subnets (3 zones in same region)
• Cloud Router
• Default Internet Route:
      0.0.0.0/0 → default-internet-gateway
• Firewall Rules:
      - Allow SSH (restricted CIDR)
      - Allow HTTP (80)
      - Allow HTTPS (443)
      - Allow App Port (8080)
      - Deny-all ingress (lower priority)

All resources use parameterized naming:
<env>-<name_suffix>

------------------------------------------------------------
GCP DEPLOYMENT STEPS
------------------------------------------------------------

cd gcp

terraform init
terraform validate

terraform plan \
  -var="project_id=<your-project-id>" \
  -var="env=demo" \
  -var="name_suffix=v1"

terraform apply \
  -var="project_id=<your-project-id>" \
  -var="env=demo" \
  -var="name_suffix=v1"

Destroy if needed:

terraform destroy \
  -var="project_id=<your-project-id>" \
  -var="env=demo" \
  -var="name_suffix=v1"

------------------------------------------------------------
CONTINUOUS INTEGRATION
------------------------------------------------------------

GitHub Actions workflow:
.github/workflows/terraform-ci.yml

Runs on every Pull Request to main.

Checks:
• terraform fmt -check -recursive
• terraform init -backend=false
• terraform validate

Runs for both:
• aws/
• gcp/

Pull requests cannot be merged unless CI passes.

------------------------------------------------------------
SECURITY & BEST PRACTICES
------------------------------------------------------------

• No hard-coded values in Terraform resources
• All configurable values declared in variables.tf
• terraform.tfvars excluded from version control
• Unique naming supports multiple deployments
• SSH protocol used for Git
• Development performed in fork repository
• PRs raised from fork → organization main
• Branch protection rules enabled

------------------------------------------------------------
OUTPUTS
------------------------------------------------------------

After successful deployment:

terraform output

AWS:
• VPC ID
• Public Subnet IDs
• Private Subnet IDs
• Route Table IDs

GCP:
• VPC Name
• Subnet Names
• Firewall Rule Names
• Router Name

------------------------------------------------------------
DESIGN PRINCIPLES
------------------------------------------------------------

• Provider-separated architecture
• Parameterized infrastructure
• No sensitive data committed
• CI-enforced formatting and validation
• Branch protection prevents direct merges
• Reusable Terraform modules

------------------------------------------------------------
END OF DOCUMENT
------------------------------------------------------------