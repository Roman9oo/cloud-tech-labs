resource "aws_iam_role" "lambda_save_course_role" {
  name = "lambda-save-course-role"

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

resource "aws_iam_role_policy" "lambda_save_course_policy" {
  name = "lambda-save-course-policy"
  role = aws_iam_role.lambda_save_course_role.id

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
        Effect = "Allow",
        Action = ["dynamodb:PutItem"],
        Resource : aws_dynamodb_table.courses.arn
      }
    ]
  })
}

data "archive_file" "lambda_save_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/save-course.js"
  output_path = "${path.module}/lambda/save-course.zip"
}

resource "aws_lambda_function" "save_course" {
  function_name    = "save-course"
  handler          = "save-course.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_save_course_role.arn
  filename         = data.archive_file.lambda_save_course_zip.output_path
  source_code_hash = data.archive_file.lambda_save_course_zip.output_base64sha256
}
