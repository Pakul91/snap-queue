resource "aws_dynamodb_table" "image_data_table" {
  name           = "${var.namespace}-image-data-table-${var.env}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "UserId"
  range_key      = "ImageId"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "ImageId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "${var.namespace}-image-data-table-${var.env}"
    Environment = var.env
    Namespace   = var.namespace
  }
}