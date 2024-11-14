using './log-analytics-workspace.bicep'

param name = '#{{ environment }}#{{ project }}#{{ nc-function-infrastructure }}#{{ nc_loganalytics }}#{{ subscriptionNumber }}#{{ regionNumber }}01'
param skuName = '#{{ logAnalyticsSku }}'

param location = '#{{ location }}'
param tags = {
  Tier: 'Key Vault'
  Location: '#{{ location }}'
  Environment: '#{{ environmentTag }}'
  ServiceCode: '#{{ serviceCodeTag }}'
  ServiceName: '#{{ serviceNameTag }}'
  ServiceType: '#{{ serviceTypeTag }}'
  Repo: '#{{ Build.Repository.Uri }}'
}

param resourceLockEnabled = '#{{ resourceLockEnabled }}' == 'true' ? true : false
