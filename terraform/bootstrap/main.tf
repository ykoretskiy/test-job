#################################################
################### Variables ###################
#################################################

variable "tf_state_bucket_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "profile" {
  type = string
}

#################################################
################### Providers ###################
#################################################

provider "aws" {
  region  = var.region
  profile = var.profile
}

#################################################
############## Provider Versions ################
#################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.31.0"
    }
  }
}

#################################################
################### Data ########################
#################################################
data "aws_caller_identity" "current" {}

#################################################
################### Localsa #####################
#################################################
locals {
  tf_state_bucket_name = "${var.project_name}-${var.tf_state_bucket_name}"
}

#################################################
################### Resources ###################
#################################################

resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = local.tf_state_bucket_name

  lifecycle {
    prevent_destroy = false
  }

  force_destroy = true 
  
  tags = {
    Project     = var.project_name
    Environment = "All"
    CreatedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_side_encryption" {
  bucket = aws_s3_bucket.tf-state-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.tf-state-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_dynamodb_table" "tf-state-table" {
  name           = local.tf_state_bucket_name
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = var.project_name
    Environment = "All"
    CreatedBy   = "Terraform"
  }
}

#################################################
################### Output ######################
#################################################

output "tf_state_bucket_name" {
  value = aws_s3_bucket.tf-state-bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf-state-table.id
}
