targetScope = 'resourceGroup'

param environmentName string
param location string

output RESOURCE_GROUP_ID string = resourceGroup().id

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: '${environmentName}-identity'
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${environmentName}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${environmentName}-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${environmentName}-functionapp'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: '/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${environmentName}-plan'
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: '<storage-connection-string>'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
  tags: {
    'azd-service-name': 'agent1-gk'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'functionapp-diagnostics'
  properties: {
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: '<log-analytics-workspace-id>'
  }
  scope: functionApp
}

resource roleAssignmentBlob 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, resourceGroup().id, 'blob-data-contributor')
  properties: {
    principalId: '<managed-identity-id>'
    roleDefinitionId: '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignmentQueue 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, resourceGroup().id, 'queue-data-contributor')
  properties: {
    principalId: '<managed-identity-id>'
    roleDefinitionId: '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/974c5e8b-45b9-4653-ba55-5f855dd0fb88'
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignmentTable 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, resourceGroup().id, 'table-data-contributor')
  properties: {
    principalId: '<managed-identity-id>'
    roleDefinitionId: '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignmentMetrics 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, resourceGroup().id, 'metrics-publisher')
  properties: {
    principalId: '<managed-identity-id>'
    roleDefinitionId: '/subscriptions/${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
    principalType: 'ServicePrincipal'
  }
}
