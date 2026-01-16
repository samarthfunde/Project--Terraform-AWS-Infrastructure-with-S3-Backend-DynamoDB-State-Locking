# copy from documentation
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "samarth-state-table"
  billing_mode   = "PAY_PER_REQUEST"  #...... PROVISIONED = means continuesly billing
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S" # ...... S = means string
  }

  tags = {
    Name        = "samarth-state-table"
  }
}