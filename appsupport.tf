resource "aws_s3_bucket" "staticimg" {
    bucket = "hc-workshop-2.0-assets-${var.unit_prefix}"
    acl = "public-read"
    force_destroy = true
}

resource "aws_s3_bucket_policy" "staticimgpol" {
    bucket = aws_s3_bucket.staticimg.id

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "ImageBucketPolicy",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.staticimg.id}/*"
    }
  ]
}
POLICY
}