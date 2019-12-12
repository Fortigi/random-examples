$TenantId = "..."
$ClientID = "..."
$ClientSecret = "..."

$Body = @{client_id = $ClientID; client_secret = $ClientSecret; grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; }
$OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
$AccessToken = $OAuthReq.access_token

$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/" -Method Get