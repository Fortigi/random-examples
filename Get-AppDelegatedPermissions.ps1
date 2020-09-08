[CmdletBinding()]
param()

#Connect
Connect-AzureAD

#Create array we will use to gather data into.
[array]$Report = $null
 
#Get all service principals
Write-Verbose -Message "Retrieving all Azure AD Service Principals"
$SPs = Get-AzureADServicePrincipal -All $true
 
#Get Application Permissions (access without a user)
Foreach ($SP in $SPs) {
    Write-Verbose -Message "Processing $($SP.DisplayName)"

    [array]$AppOAuth2Permissions = Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $SP.ObjectID

    Foreach ($AppOAuth2Permission in $AppOAuth2Permissions) {
    
        $Principal = $null
        If ($AppOAuth2Permission.PrincipalId) {
            $Principal = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.PrincipalId -ErrorAction SilentlyContinue
        }

        if ($Principal) {
            $Resource = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.ResourceId
            $Application = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.ClientId
            [array]$Scopes = $AppOAuth2Permission.Scope.Split(" ")

            Foreach ($Scope in $Scopes) {
                $Row = New-Object PSObject
                $Row | Add-Member NoteProperty App                    $Application.DisplayName
                $Row | Add-Member NoteProperty Resource               $Resource.DisplayName
                $Row | Add-Member NoteProperty Permission             $Scope
                $Row | Add-Member NoteProperty user                   $Principal.UserPrincipalName
                $Row | Add-Member NoteProperty ExpiryTime             $AppOAuth2Permission.ExpiryTime

                $Report += $Row
            }
        }
    }
}

Write-Host "Full List"
$Report | Format-Table

Write-Host "Filter for active.."
$ActiveReport = $Report | Where-Object { $_.ExpiryTime -gt (Get-Date) }

Write-Host "Filter for . meaning all of something.. all mail, all files.. you profile.. not just your email address or your id"
$ActiveReport | Where-Object { $_.Permission.contains(".") } | Format-Table

Write-Host "Filtered, especially for Mail. or Files."
$ActiveReport | Where-Object { $_.Permission.contains("Mail.") -or $_.Permission.contains("Files.") } | Format-Table

