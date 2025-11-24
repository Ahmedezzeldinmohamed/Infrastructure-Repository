Obelion Cloud Automation Assessment - Infrastructure Repository

This repository contains the Infrastructure as Code (IaC) required for Task Group A (AWS Infrastructure Creation) and Task Group B-3 (CPU Alerting). It also includes the detailed migration plan for Task Group C (Azure Migration).

1. Task Group A: AWS Infrastructure

All resources are defined in main.tf and variables.tf.

Resource

Configuration

AWS Service

Backend Machine

1 Core, 1 GB RAM, 8 GB Disk, Ubuntu 22.04

EC2 (t3.micro)

Frontend Machine

1 Core, 1 GB RAM, 8 GB Disk, Ubuntu 22.04

EC2 (t3.micro)

MySQL Database

Community 8.0, Lowest plan, No internet exposure

RDS (db.t3.micro)

Deployment Steps (Terraform)

Initialization: terraform init

Plan: terraform plan -var-file="terraform.tfvars"

Apply: terraform apply -var-file="terraform.tfvars"

2. Task Group B-3: CPU Alerting

The alerting mechanism is defined in monitoring.tf.

Target: LaravelBackendMachine (EC2 Instance).

Condition: Average CPUUtilization > 50%.

Duration: 2 consecutive periods (2 minutes).

Action: Send notification to a specified email address via AWS SNS.

Note: The user must confirm the subscription email sent by AWS SNS after running terraform apply.

3. Task Group C: Azure Migration Plan (Optional)

The detailed, four-stage plan for migrating the entire architecture (DB, Assets, Compute) from AWS to Azure with minimal downtime is available in the file: azure_migration_plan.md.
