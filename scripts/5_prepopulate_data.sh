#!/bin/bash

export REGION="$1"
export MYSQL_USER="$2"
export MYSQL_PASS="$3"
export VAULT_TOKEN="$4"
export TABLE_PRODUCT="$5"
export S3_BUCKET="$6"

# Create mysql database
echo "Creating database..."
python3 /root/javaperks-aws-single-server/scripts/create_db.py customer-db.service.$REGION.consul $MYSQL_USER $MYSQL_PASS $VAULT_TOKEN $REGION

# load product data
echo "Loading product data..."
python3 /root/javaperks-aws-single-server/scripts/product_load.py $TABLE_PRODUCT $REGION

# upload product-app images
echo "Cloneing product images..."
git clone https://github.com/kevincloud/javaperks-product-api.git /root/components

# Upload images to S3
echo "Uploading product images..."
aws s3 cp /root/components/javaperks-product-api/images/ s3://$S3_BUCKET/images/ --recursive --acl public-read
