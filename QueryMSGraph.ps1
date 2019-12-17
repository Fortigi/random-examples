$TenantId = "..."
$ClientID = "..."
$ClientSecret = "..."

$Body = @{client_id = $ClientID; client_secret = $ClientSecret; grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; }
$OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
$AccessToken = $OAuthReq.access_token
`
#Get Users
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/" -Method Get
$Result.value

#Get Specific User
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/" -Method Get
$UserId = ($Result.Value | Where-Object {$_.userPrincipalName -eq "user@tenant.onmicrosoft.com"}).id

#Get Specific Group
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/groups/" -Method Get
$GroupID = ($Result.Value | Where-Object {$_.DisplayName -eq "GroupName"}).id

#Add member te group
$Body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/users/$UserId"} | ConvertTo-Json
Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri ('https://graph.microsoft.com/beta/groups/'+$GroupID+'/members/$ref') -Method Post -Body $Body -ContentType "application/json"

#Get Global Admin Role
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/directoryRoles/" -Method Get
$GlobalAdminRoleId = ($Result.Value | Where-Object {$_.DisplayName -eq "Company Administrator"}).id

#Add user to global admins
$Body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/users/$UserId"} | ConvertTo-Json
Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken"} -Uri ('https://graph.microsoft.com/beta/directoryRoles/'+$GlobalAdminRoleId+'/members/$ref') -Method Post -Body $Body -ContentType "application/json"



