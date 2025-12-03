#!/usr/bin/env bash
set -euo pipefail

BUCKET_NAME="${1:-my-terraform-state-bucket-TODO}"
DDB_TABLE="${2:-terraform-state-lock}"
REGION="${3:-us-east-1}"

aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" || true
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name "$DDB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" || true

echo "Backend bootstrapped: s3://$BUCKET_NAME with dynamodb table $DDB_TABLE"

#  chmod +x scripts/bootstrap-backend.sh
# ./scripts/bootstrap-backend.sh my-terraform-state-bucket-12345 terraform-state-lock us-east-1
# Important: secure the S3 bucket (block public access) and enable encryption.
