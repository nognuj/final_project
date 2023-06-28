resource "aws_dynamodb_table" "paymentTransactions" {
  name           = "paymentTransactions2"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
}
