resource "azurerm_storage_account" "storage" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  allow_blob_public_access  = false
  enable_https_traffic_only = true

  network_rules {
    default_action             = var.network_rules_default_action
    ip_rules                   = var.ip_rules[*].ip_rule
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }
}

resource "azurerm_storage_container" "container" {
  for_each = { for container in var.containers : container.name => container }

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

locals {
  containersmap = { for container in var.containers : container.name => container }

  flattenroleassignments = flatten([
    for container_key, container in local.containersmap : [
      for role_assignment in container.role_assignments : {
        name                 = role_assignment.name
        role_definition_name = role_assignment.role_definition_name
        object_id            = role_assignment.object_id
        container_resourceid = azurerm_storage_container.container[container_key].resource_manager_id
        container_name       = container.name
      }
    ]
  ])
}

resource "azurerm_role_assignment" "reader_roleassignment" {
  for_each             = { for role in local.flattenroleassignments : "container${role.object_id}.${role.role_definition_name}.${role.container_name}" => role }
  scope                = each.value.container_resourceid
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.object_id
}

resource "azurerm_role_assignment" "roleassignment_account_on_account" {
  for_each = { for role in var.role_assignments : "account${role.object_id}.${role.role_definition_name}.${role.name}" => role }

  scope                = azurerm_storage_account.storage.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.object_id
}

resource "azurerm_storage_share" "share" {
  for_each             = var.shares
  name                 = each.value.name
  quota                = each.value.quota
  storage_account_name = azurerm_storage_account.storage.name
}


