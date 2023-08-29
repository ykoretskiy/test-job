#################################################
################### Variables ###################
#################################################
variable "tf_state_bucket_name" { type = string }

variable "project_name" { type = string }

variable "region" { type = string }

variable "profile" { type = string }


#################################################
################### Providers ###################
#################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

#################################################
################### Locals ######################
#################################################



locals {
  app_lambda_function_name = "increase_number_lambda"
  app_lambda_file_path     = "src/lambda_function.py"
  app_lambda_zip_path      = "${local.app_lambda_function_name}.zip"

  auth_lambda_function_name = "auth_lambda"
  auth_lambda_file_path     = "src/index.js"
  auth_lambda_zip_path      = "${local.auth_lambda_function_name}.zip"

  tags = {
    Project   = var.project_name
    Module    = "lambda"
    CreatedBy = "Terraform"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.cwd}/${local.app_lambda_file_path}"
  output_path = local.app_lambda_zip_path
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "increase_number_lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = ["*"]
  }
}


resource "aws_iam_role" "lambda_role" {
  name               = "${local.app_lambda_function_name}_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  inline_policy {
    name   = "${local.app_lambda_function_name}_policy"
    policy = data.aws_iam_policy_document.increase_number_lambda.json
  }

  tags = local.tags
}


resource "aws_lambda_function" "increase_number_lambda" {
  function_name = local.app_lambda_function_name
  filename      = local.app_lambda_zip_path
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 5


  source_code_hash = data.archive_file.lambda.output_base64sha256
  tags             = local.tags

  depends_on = [data.archive_file.lambda]
}

resource "aws_lambda_function_url" "increase_number_lambda" {
  function_name      = aws_lambda_function.increase_number_lambda.function_name
  authorization_type = "NONE"
}
