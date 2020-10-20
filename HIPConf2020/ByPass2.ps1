$AccessToken = ""

#Get User
$Result = Invoke-RestMethod -Headers @{Authorization = "Bearer $AccessToken" } -Uri "https://graph.microsoft.com/beta/me/" -Method Get
$Me = $Result
$Me | Select-Object id, displayName, userPrincipalName | Format-List

#Get users onedrive Id
$UserId = $Me.id
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
    Invoke-WebRequest -Method get -Uri $Result.'@microsoft.graph.downloadUrl' -OutFile "C:\Users\HipConfRed\Documents\GIT\Download\ByPass2\$FileName"
}