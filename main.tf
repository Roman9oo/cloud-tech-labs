provider "aws" {
  region = "eu-central-1"
}

module "label_authors" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "roman"
  name      = "authors"
  stage     = "dev"
}

resource "aws_dynamodb_table" "authors" {
  name         = module.label_authors.id
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.label_authors.tags
}

module "label_courses" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "roman"
  name      = "courses"
  stage     = "dev"
}

resource "aws_dynamodb_table" "courses" {
  name         = module.label_courses.id
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.label_courses.tags
}
