resource "aws_iam_role" "lambda_get_all_authors_role" {
  name = "lambda-get-all-authors-role"

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

resource "aws_iam_role_policy" "lambda_get_all_authors_policy" {
  name = "lambda-get-all-authors-policy"
  role = aws_iam_role.lambda_get_all_authors_role.id

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
        Resource = aws_dynamodb_table.authors.arn
      }
    ]
  })
}

data "archive_file" "lambda_get_all_authors_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/get-all-authors.mjs"
  output_path = "${path.module}/lambda/get-all-authors.mjs.zip"
}


resource "aws_lambda_function" "get_all_authors" {
  function_name    = "get-all-authors"
  handler          = "get-all-authors.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_get_all_authors_role.arn
  filename         = data.archive_file.lambda_get_all_authors_zip.output_path
  source_code_hash = data.archive_file.lambda_get_all_authors_zip.output_base64sha256
}
