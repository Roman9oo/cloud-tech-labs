resource "aws_iam_role" "lambda_get_all_courses_role" {
  name = "lambda-get-all-courses-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_get_all_courses_policy" {
  name = "lambda-get-all-courses-policy"
  role = aws_iam_role.lambda_get_all_courses_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:Scan"],
        Resource = aws_dynamodb_table.courses.arn
      }
    ]
  })
}
data "archive_file" "lambda_get_all_courses_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/get-all-courses.mjs"
  output_path = "${path.module}/lambda/get-all-courses.mjs.zip"
}

resource "aws_lambda_function" "get_all_courses" {
  function_name    = "get-all-courses"
  handler          = "get-all-courses.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_get_all_courses_role.arn
  filename         = data.archive_file.lambda_get_all_courses_zip.output_path
  source_code_hash = data.archive_file.lambda_get_all_courses_zip.output_base64sha256
}
