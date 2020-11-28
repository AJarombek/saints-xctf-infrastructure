/**
 * Authentication AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
  public_cidr = "0.0.0.0/0"
}

#-------------------
# Existing Resources
#-------------------

data "aws_vpc" "application-vpc" {
  tags = {
    Name = "application-vpc"
  }
}

data "aws_subnet" "application-vpc-public-subnet-0" {
  tags = {
    Name = "saints-xctf-com-lisag-public-subnet"
  }
}

data "aws_subnet" "application-vpc-public-subnet-1" {
  tags = {
    Name = "saints-xctf-com-megank-public-subnet"
  }
}

#------------------------------------------
# SaintsXCTF Auth Lambda Function Resources
#------------------------------------------

# ---------------------------------------
# Authorizer Lambda Function (Standalone)
# ---------------------------------------

resource "aws_lambda_function" "authorizer" {
  function_name = "SaintsXCTFAuthorizer${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFAuthorizer.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFAuthorizer.zip")
  timeout = 10
  memory_size = 128

  environment {
    variables = {
      ENV = local.env
    }
  }

  tags = {
    Name = "saints-xctf-com-lambda-authorizer"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "authorizer-log-group" {
  name = "/aws/lambda/SaintsXCTFAuthorizer${upper(local.env)}"
  retention_in_days = 7
}

# -----------------------------------
# Rotate Lambda Function (Standalone)
# -----------------------------------

resource "aws_lambda_function" "rotate" {
  function_name = "SaintsXCTFRotate${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFRotate.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.rotate-lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFRotate.zip")
  timeout = 10
  memory_size = 128

  tags = {
    Name = "saints-xctf-com-lambda-rotate"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_lambda_permission" "rotate-secrets-manager-permission" {
  action = "lambda:InvokeFunction"
  statement_id = "RotateSecretsManager"
  function_name = aws_lambda_function.rotate.function_name
  principal = "secretsmanager.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "rotate-log-group" {
  name = "/aws/lambda/SaintsXCTFRotate${upper(local.env)}"
  retention_in_days = 7
}

resource "aws_iam_role" "rotate-lambda-role" {
  name = "rotate-secret-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/rotate-lambda-role.json")
  description = "IAM role for a SecretsManager secret rotation AWS Lambda function"
}

resource "aws_iam_policy" "rotate-lambda-policy" {
  name = "rotate-secret-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/rotate-lambda-policy.json")
  description = "IAM policy for a SecretsManager secret rotation AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "rotate-lambda-policy-attachment" {
  role = aws_iam_role.rotate-lambda-role.name
  policy_arn = aws_iam_policy.rotate-lambda-policy.arn
}

# ------------------------------------------
# Authenticate Lambda Function (API Gateway)
# ------------------------------------------

resource "aws_lambda_function" "authenticate" {
  function_name = "SaintsXCTFAuthenticate${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFAuthenticate.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFAuthenticate.zip")
  memory_size = 1792
  timeout = 10
  publish = true

  environment {
    variables = {
      ENV = local.env
    }
  }

  tags = {
    Name = "saints-xctf-com-lambda-authenticate"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_lambda_alias" "authenticate-alias" {
  function_name = aws_lambda_function.token.function_name
  function_version = aws_lambda_function.token.version
  name = "SaintsXCTFAuthenticate${upper(local.env)}Current"
}

resource "aws_lambda_provisioned_concurrency_config" "authenticate" {
  function_name = aws_lambda_function.authenticate.function_name
  provisioned_concurrent_executions = 1
  qualifier = aws_lambda_alias.authenticate-alias.name
}

resource "aws_cloudwatch_log_group" "authenticate-log-group" {
  name = "/aws/lambda/SaintsXCTFAuthenticate${upper(local.env)}"
  retention_in_days = 7
}

# -----------------------------------
# Token Lambda Function (API Gateway)
# -----------------------------------

resource "aws_lambda_function" "token" {
  function_name = "SaintsXCTFToken${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFToken.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.token-lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFToken.zip")
  memory_size = 1792
  timeout = 10
  publish = true

  environment {
    variables = {
      ENV = local.env
    }
  }

  vpc_config {
    security_group_ids = [module.lambda-auth-token-security-group.security_group_id[0]]
    subnet_ids = [
      data.aws_subnet.application-vpc-public-subnet-0.id,
      data.aws_subnet.application-vpc-public-subnet-1.id
    ]
  }

  tags = {
    Name = "saints-xctf-com-lambda-token"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_lambda_alias" "token-alias" {
  function_name = aws_lambda_function.token.function_name
  function_version = aws_lambda_function.token.version
  name = "SaintsXCTFToken${upper(local.env)}Current"
}

resource "aws_lambda_provisioned_concurrency_config" "token" {
  function_name = aws_lambda_function.token.function_name
  provisioned_concurrent_executions = 1
  qualifier = aws_lambda_alias.token-alias.name
}

module "lambda-auth-token-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name = "saints-xctf-auth-token-lambda-security"
  tag_name = "saints-xctf-auth-token-lambda-security"
  vpc_id = data.aws_vpc.application-vpc.id

  # Optional arguments
  sg_rules = [
    {
      # All Inbound traffic
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # All Outbound traffic
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    }
  ]

  description = "SaintsXCTF Auth Token Lambda Function Security Group"
}

resource "aws_cloudwatch_log_group" "token-log-group" {
  name = "/aws/lambda/SaintsXCTFToken${upper(local.env)}"
  retention_in_days = 7
}

resource "aws_iam_role" "token-lambda-role" {
  name = "token-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/token-lambda-role.json")
  description = "IAM role for a JWT request AWS Lambda function"
}

resource "aws_iam_policy" "token-lambda-policy" {
  name = "token-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/token-lambda-policy.json")
  description = "IAM policy for a JWT request AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "token-lambda-policy-attachment" {
  role = aws_iam_role.token-lambda-role.name
  policy_arn = aws_iam_policy.token-lambda-policy.arn
}

# ----------------
# Shared Resources
# ----------------

resource "aws_iam_role" "lambda-role" {
  name = "authorizer-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/lambda-role.json")
  description = "IAM role for logging and accessing secrets from an AWS Lambda function"
}

resource "aws_iam_policy" "lambda-policy" {
  name = "authorizer-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/lambda-policy.json")
  description = "IAM policy for logging and accessing secrets from an AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}