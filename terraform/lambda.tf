data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_policy" {
  source_json = data.aws_iam_policy.lambda_basic_execution.policy

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = ["arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.self.account_id}:table/*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "MyLambdaPolicy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "function" {
  function_name = "todo-function"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.10"

  filename         = data.archive_file.file.output_path
  source_code_hash = data.archive_file.file.output_base64sha256

  environment {
    variables = {
      tableName = var.tableName
    }
  }
}

data "archive_file" "file" {
  type        = "zip"
  output_path = "${path.module}/lambda/app/index.zip"
  source_file = "${path.module}/lambda/app/index.py"
}
