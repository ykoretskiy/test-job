data "archive_file" "auth_lambda" {
  type        = "zip"
  source_file = "${path.cwd}/${local.auth_lambda_file_path}"
  output_path = local.auth_lambda_zip_path
}

data "aws_iam_policy_document" "auth_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "auth_lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = ["*"]
  }
}


resource "aws_iam_role" "auth_lambda_role" {
  name               = "${local.auth_lambda_function_name}_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.auth_lambda_assume_role_policy.json

  inline_policy {
    name   = "${local.auth_lambda_function_name}_policy"
    policy = data.aws_iam_policy_document.auth_lambda.json
  }

  tags = local.tags
}


resource "aws_lambda_function" "auth_lambda" {
  function_name    = local.auth_lambda_function_name
  filename         = local.auth_lambda_zip_path
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  role             = aws_iam_role.auth_lambda_role.arn
  timeout          = 5
  publish          = true
  source_code_hash = data.archive_file.auth_lambda.output_base64sha256
  tags             = local.tags

  depends_on = [data.archive_file.auth_lambda]
}
