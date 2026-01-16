resource "aws_s3_bucket" "remote_s3"{
    bucket = "samarth-bucket-16-jan"

    tags = {
      Name  = "samarth-bucket-16-jan"
    }
}