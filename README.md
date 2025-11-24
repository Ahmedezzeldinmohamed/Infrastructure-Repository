Obelion Cloud Automation Assessment - Infrastructure Repository


<img width="959" height="424" alt="CI-CD" src="https://github.com/user-attachments/assets/93e37581-85fd-496b-ac09-5e69f9245b56" />

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


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d43b3083-c2c8-4016-ac24-1d32a5d89a0e" />


<img width="1920" height="852" alt="image" src="https://github.com/user-attachments/assets/0d3bb316-63f0-4bb1-8169-4609079f4925" />


3. Task Group C: Azure Migration Plan (Optional)

The detailed, four-stage plan for migrating the entire architecture (DB, Assets, Compute) from AWS to Azure with minimal downtime is available in the file: azure_migration_plan.md.

<img width="960" height="540" alt="Azure1" src="https://github.com/user-attachments/assets/e86ce612-d419-4cc3-9214-cf25d8767076" />

<img width="1920" height="1080" alt="azure2" src="https://github.com/user-attachments/assets/39c1e3a4-75cc-4bf4-9a62-676ee6d8272b" />



