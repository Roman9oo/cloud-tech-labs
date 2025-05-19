output "courses_table_arn" {
  value = aws_dynamodb_table.courses.arn
}

output "authors_table_arn" {
  value = aws_dynamodb_table.authors.arn
}
