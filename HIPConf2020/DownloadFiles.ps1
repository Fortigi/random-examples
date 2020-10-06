$TenantID = "3d55bf0a-1b6e-4c03-b451-810067fc76d9"
$ClientID = "128017d1-97ac-45db-895b-6b7aa9cd7040"
$ClientSecret = "TfmbMT~oicPr3334.xk4X8nK2o4~2mB~b_"

#Get an access token.
$Body = @{client_id = $ClientID; client_secret = $ClientSecret; grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; }
$OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
$AccessToken = $OAuthReq.access_token

#Get User
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/users/" -Method Get
$Users = $Result.value
$Users | Select-Object id, displayName, userPrincipalName | Format-List

#Get users onedrive Id
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
    Invoke-WebRequest -Method get -Uri $Result.'@microsoft.graph.downloadUrl' -OutFile "C:\Users\HipConfRed\Documents\GIT\Download\$FileName"
}