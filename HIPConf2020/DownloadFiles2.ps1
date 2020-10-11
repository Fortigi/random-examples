$AccessToken = "eyJ0eXAiOiJKV1QiLCJub25jZSI6InV6UGtpUjE0U2xJdmNOV0U4QXdmWXM0b1pPV1ktbHlmeWxIYmd4SWE5alEiLCJhbGciOiJSUzI1NiIsIng1dCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCIsImtpZCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTAwMDAtYzAwMC0wMDAwMDAwMDAwMDAiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC8zZDU1YmYwYS0xYjZlLTRjMDMtYjQ1MS04MTAwNjdmYzc2ZDkvIiwiaWF0IjoxNjAyNDA0NjI4LCJuYmYiOjE2MDI0MDQ2MjgsImV4cCI6MTYwMjQwODUyOCwiYWNjdCI6MCwiYWNyIjoiMSIsImFpbyI6IkUyUmdZRGplbTVUQTlhbHowdVQva3VkLytnVGREUlVKbWRLUjlPUk1rUDNaYjlYMVRRMEEiLCJhbXIiOlsicHdkIl0sImFwcF9kaXNwbGF5bmFtZSI6IlVzZXIgQ29uc2VudCBEZW1vIiwiYXBwaWQiOiIwNjYzOTg4My05NGM1LTRjZTQtOTU4ZS0zOTEyNDczOWJmMzIiLCJhcHBpZGFjciI6IjEiLCJmYW1pbHlfbmFtZSI6IkFuZGVyc29uIiwiZ2l2ZW5fbmFtZSI6Ik1yIiwiaWR0eXAiOiJ1c2VyIiwiaXBhZGRyIjoiMjEzLjE5OS4xMzQuMTIzIiwibmFtZSI6Ik1yLiBBbmRlcnNvbiIsIm9pZCI6IjNkZGM5YzViLTU4ZTEtNGUzNy05MjMyLTVlMzMxMWIzZWJjMyIsInBsYXRmIjoiMyIsInB1aWQiOiIxMDAzMjAwMEVBQjMyNkVFIiwicmgiOiIwLkFBQUFDcjlWUFc0YkEweTBVWUVBWl94MjJZT1lZd2JGbE9STWxZNDVFa2M1dnpKMEFIUS4iLCJzY3AiOiJGaWxlcy5SZWFkIG9wZW5pZCBwcm9maWxlIFVzZXIuUmVhZCBlbWFpbCIsInN1YiI6IlVMSnNfempoZzFOX1J5ZHE4T2Y2WWhDMDBxUEIxOVQ0d0VmdWNfMlY1Q00iLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiIzZDU1YmYwYS0xYjZlLTRjMDMtYjQ1MS04MTAwNjdmYzc2ZDkiLCJ1bmlxdWVfbmFtZSI6IkFuZGVyc29uQGhpcGNvbmYub25taWNyb3NvZnQuY29tIiwidXBuIjoiQW5kZXJzb25AaGlwY29uZi5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJIZUpPMEtTeTZVcWFQSzdNRnJBWUFBIiwidmVyIjoiMS4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX3N0Ijp7InN1YiI6ImZqTW9felNBak9TVUNITUhOR2ZBM2lOVm1lTXV2N0VZem5kNFItdVBDd1kifSwieG1zX3RjZHQiOjE2MDE5NjYwNjV9.qq5HRB5jEGugn-Y_b0oF5-n1S9_A_oRlaHJYsXsNjQBFzpT_syJ5EG1xO9o3GmRTRy5kP3agxSCruC4shHaswNiD-JQTH30kwD14A0SXqEK1wGoqx2xVCPtJySsj_841bGmL56YObmVOYGQZyoaN90gFwzhSdRITGhsq3GE6kTr60hGCthxuZFITJ8nCdkopon5PsdpfZfwG_1oy1-WGCiqDerkP6FRYmb38Ki0qYBCchd4OUiCMk89nYVf9tgkGoXcgseoHV1EQ1P16XFCct8gVyXOID6twaYqQoDq_3rRCf3HEejB7Xp6TX2cN_mxsvVs-RwSQ6E4k-l-Fbr4rxA"

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
    Invoke-WebRequest -Method get -Uri $Result.'@microsoft.graph.downloadUrl' -OutFile "C:\Users\HipConfRed\Documents\GIT\Download\$FileName"
}