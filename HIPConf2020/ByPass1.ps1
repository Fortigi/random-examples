$TenantID = "3d55bf0a-1b6e-4c03-b451-810067fc76d9"
$ClientID = "678ea3c7-b435-4024-b31a-a49dbf37de11"
$ClientSecret = ""

#Get an access token.
$Body = @{client_id = $ClientID; client_secret = $ClientSecret; grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; }
$OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
$AccessToken = $OAuthReq.access_token

#Get all users
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/" -Method Get
$Users = $Result.value
$Users | Select-Object id, displayName, userPrincipalName | Format-List

#Get Mr Andersons ID and OneDrive ID
$User = $Users | Where-Object { $_.userPrincipalName -eq "Anderson@hipconf.onmicrosoft.com" }
$UserId = $User.id
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/$UserId/drive" -Method Get
$DriveId = $Result.id

#Get files on one drive
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/drives/$DriveId/root/children" -Method Get
$Files = $Result.value
$Files | Select-Object name, size, id

#Download all the files...
Foreach ($File in $Files) {
    $FileId = $File.id
    $FileName = $File.name
    $Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/drives/$DriveId/items/$FileId" -Method Get
    Invoke-WebRequest -Method get -Uri $Result.'@microsoft.graph.downloadUrl' -OutFile "C:\Users\HipConfRed\Documents\GIT\Download\ByPass1\$FileName"
}