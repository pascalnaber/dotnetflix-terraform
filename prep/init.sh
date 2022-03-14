terraform init \
  -backend-config=storage_account_name=sadnfterraformnonprodwe \
  -backend-config=container_name=terraformstate \
  -backend-config=key=dnf.nonprod.tfstate \
  -backend-config=resource_group_name=rg-dnf-terraform-nonprod-we-001 \
  -backend-config=tenant_id=$ARM_TENANT_ID \
  -backend-config=subscription_id=$ARM_SUBSCRIPTION_ID \
  -backend-config=client_id=$ARM_CLIENT_ID \
  -backend-config=client_secret=$ARM_CLIENT_SECRET