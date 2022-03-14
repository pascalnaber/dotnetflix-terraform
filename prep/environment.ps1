# $Env:ARM_SUBSCRIPTION_ID = $(az account show --query id -o tsv)
# $Env:ARM_TENANT_ID = $(az account show --query tenantId -o tsv)
# $Env:ARM_CLIENT_ID = $(az keyvault secret show --subscription $ARM_SUBSCRIPTION_ID --name "spn-dnf-devops-nonprod-appid" --vault-name kv-dnf-devops-nonprod-we --query value -o tsv)
# $Env:ARM_CLIENT_SECRET = $(az keyvault secret show --subscription $ARM_SUBSCRIPTION_ID --name "spn-dnf-devops-nonprod-secret" --vault-name kv-dnf-devops-nonprod-we --query value -o tsv)

[System.Environment]::SetEnvironmentVariable('ARM_SUBSCRIPTION_ID',$(az account show --query id -o tsv))
[System.Environment]::SetEnvironmentVariable('ARM_TENANT_ID',$(az account show --query tenantId -o tsv))
[System.Environment]::SetEnvironmentVariable('ARM_CLIENT_ID',$(az keyvault secret show --subscription $Env:ARM_SUBSCRIPTION_ID --name "spn-dnf-devops-nonprod-appid" --vault-name kv-dnf-devops-nonprod-we --query value -o tsv))
[System.Environment]::SetEnvironmentVariable('ARM_CLIENT_SECRET',$(az keyvault secret show --subscription $Env:ARM_SUBSCRIPTION_ID --name "spn-dnf-devops-nonprod-secret" --vault-name kv-dnf-devops-nonprod-we --query value -o tsv))
