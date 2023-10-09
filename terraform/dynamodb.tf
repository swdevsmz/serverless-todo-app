resource "aws_dynamodb_table" "todo-dynamodb-table" {
  name           = var.tableName
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
