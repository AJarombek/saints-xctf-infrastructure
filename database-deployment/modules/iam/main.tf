/**
 * IAM roles and policies for the SaintsXCTF RDS database deployment lambda function
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

resource "aws_iam_role" "lambda-role" {
  name               = "saints-xctf-database-deployment-lambda-role"
  assume_role_policy = file("${path.module}/assume-role-policy.json")

  tags = {
    Name        = "saints-xctf-database-deployment-lambda-role"
    Environment = "all"
    Application = "saints-xctf"
  }
}

resource "aws_iam_policy" "lambda-policy" {
  name   = "saints-xctf-database-deployment-lambda-policy"
  path   = "/saintsxctf/"
  policy = file("${path.module}/policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-policy.arn
  role       = aws_iam_role.lambda-role.name
}