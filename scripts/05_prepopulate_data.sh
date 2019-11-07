#!/bin/bash

# Create mysql database
echo "Creating database..."
python3 /root/javaperks-aws-single-server/scripts/create_db.py customer-db.service.$REGION.consul $MYSQL_USER $MYSQL_PASS $VAULT_TOKEN $REGION

# load product data
echo "Loading product data..."
python3 /root/javaperks-aws-single-server/scripts/product_load.py $TABLE_PRODUCT $REGION

# upload product-app images
echo "Cloneing product images..."
git clone https://github.com/kevincloud/javaperks-product-api.git /root/javaperks-product-api

# Upload images to S3
echo "Uploading product images..."
aws s3 cp /root/javaperks-product-api/images/ s3://$S3_BUCKET/images/ --recursive --acl public-read
