resource "aws_iam_role" "lambda_get_course_role" {
  name = "lambda-get-course-role"

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

resource "aws_iam_role_policy" "lambda_get_course_policy" {
  name = "lambda-get-course-policy"
  role = aws_iam_role.lambda_get_course_role.id

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
        Action   = ["dynamodb:GetItem"],
        Resource = aws_dynamodb_table.courses.arn
      }
    ]
  })
}

data "archive_file" "lambda_get_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/get-course.mjs"
  output_path = "${path.module}/lambda/get-course.mjs.zip"
}

resource "aws_lambda_function" "get_course" {
  function_name    = "get-course"
  handler          = "get-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_get_course_role.arn
  filename         = data.archive_file.lambda_get_course_zip.output_path
  source_code_hash = data.archive_file.lambda_get_course_zip.output_base64sha256
}
