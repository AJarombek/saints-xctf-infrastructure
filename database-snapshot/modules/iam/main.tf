/**
 * IAM roles and policies for the saintsxctf RDS database backup/restore lambda functions
 * Author: Andrew Jarombek
 * Date: 7/19/2020
 */

resource "aws_iam_role" "lambda-role" {
  name = "saints-xctf-rds-backup-lambda-role"
  assume_role_policy = file("${path.module}/role.json")

  tags = {
    Name = "saints-xctf-rds-backup-lambda-role"
    Environment = "all"
    Application = "saints-xctf"
  }
}

resource "aws_iam_policy" "rds-backup-lambda-policy" {
  name = "rds-backup-lambda-policy"
  path = "/saintsxctf/"
  policy = file("${path.module}/policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy-attachment" {
  policy_arn = aws_iam_policy.rds-backup-lambda-policy.arn
  role = aws_iam_role.lambda-role.name
}