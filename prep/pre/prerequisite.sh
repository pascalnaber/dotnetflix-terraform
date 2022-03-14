#!/bin/bash
set -xe

file_path=`dirname "$0"`
echo "file_path $file_path"

. $file_path/$1
# Run this like: ./prerequisite.sh nonprod.config
# This script is needed to run as a user (not as a spn)
# It creates the resourcegroup and storage account and keyvault needed by terraform
# makes the app registration and assigns the owner role on the subscription
# Also configures access rights on the keyvault for the app registration

az account set --subscription $SUBSCRIPTION

TERRAFORM_RESOURCEGROUP_NAME=rg-${PROJECT}-terraform-$STAGE-we-001
TERRAFORM_STORAGEACCOUNT_NAME="sa${PROJECT}terraform${STAGE}we"
KEYVAULT_NAME="kv-${PROJECT}-devops-${STAGE}-we"
LOCATION=westeurope
SPN_NAME=spn-${PROJECT}-devops-$STAGE
KEYVAULT_SECRETNAME_SPNAPPID=spn-${PROJECT}-devops-$STAGE-appid
KEYVAULT_SECRETNAME_SPNSECRET=spn-${PROJECT}-devops-$STAGE-secret

# Create Resourcegroup
az group create -l $LOCATION -n $TERRAFORM_RESOURCEGROUP_NAME

# Create Storage Account with Container
az storage account create -n $TERRAFORM_STORAGEACCOUNT_NAME -g $TERRAFORM_RESOURCEGROUP_NAME --sku Standard_LRS
az storage container create -n terraformstate --account-name $TERRAFORM_STORAGEACCOUNT_NAME

# Create KeyVault with ipaddresses for whitelisting
az keyvault create --name $KEYVAULT_NAME --resource-group $TERRAFORM_RESOURCEGROUP_NAME --enabled-for-template-deployment --enable-purge-protection || echo "Vault already exists"

# Create SPN

APP_NAME="$SPN_NAME"

# lookup in AAD
SPN_ID=$(az ad sp list --filter "displayname eq '$APP_NAME'" --query "[].appId" -o tsv)
# lookup in Keyvault
KV_ID=$(az keyvault secret list --vault-name $KEYVAULT_NAME --query "[?ends_with(id, '$KEYVAULT_SECRETNAME_SPNSECRET')].id" -o tsv)

if [ -z "$SPN_ID" ] || [ -z "$KV_ID" ]; then
    
    SPN_PASSWORD=$(az ad sp create-for-rbac --skip-assignment --name "$SPN_NAME" --query password --output tsv)
    az keyvault secret set --vault-name $KEYVAULT_NAME --name $KEYVAULT_SECRETNAME_SPNSECRET --value $SPN_PASSWORD
    
    sleep 30
    echo "SPN $SPN_NAME created"
else
    echo "SPN $SPN_NAME already exists"
fi   

SPN_ID=$(az ad sp list --filter "displayname eq '$APP_NAME'" --query "[].appId" -o tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name $KEYVAULT_SECRETNAME_SPNAPPID --value $SPN_ID

# Give SPN access on keyvault
SPN_OBJECTID=$(az ad sp list --filter "displayname eq '$APP_NAME'" --query "[].objectId" -o tsv)
az keyvault set-policy --name $KEYVAULT_NAME --resource-group $TERRAFORM_RESOURCEGROUP_NAME --object-id $SPN_OBJECTID --secret-permissions get list 

# Assign Ownerrole to SPN
az role assignment create --assignee $SPN_OBJECTID --role "Owner"

echo "Finished with the prerequisites."