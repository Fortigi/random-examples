#Connect
Connect-AzureAD

#Create array we will use to gather data into.
[array]$Report = $null


#Get all service principles
$SPs = Get-AzureADServicePrincipal -All $true


#Get Application Permissions (access without a user)
Foreach ($SP in $SPs) {

    [array]$AppOAuth2Permissions = Get-AzureADServicePrincipalOAuth2PermissionGrant -ObjectId $SP.ObjectID

    Foreach ($AppOAuth2Permission in $AppOAuth2Permissions) {
    
        #if the application has a secret or a certificate.. which means it can actualy use the permissions without a user being present
        $Principal = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.PrincipalId -ErrorAction SilentlyContinue

        if ($Principal) {
            $Resource = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.ResourceId
            $Application = Get-AzureADObjectByObjectId -ObjectIds $AppOAuth2Permission.ClientId
            [array]$Scopes = $AppOAuth2Permission.Scope.Split(" ")

            Foreach ($Scope in $Scopes) {
                $Row = New-Object PSObject
                $Row | add-member Noteproperty App                    $Application.DisplayName
                $Row | add-member Noteproperty Resource               $Resource.DisplayName
                $Row | add-member Noteproperty Permission             $Scope
                $Row | add-member Noteproperty user                   $Principal.UserPrincipalName
                $Row | add-member Noteproperty ExpiryTime             $AppOAuth2Permission.ExpiryTime

                $Report += $Row
                }
            }

    }
}

$Report | Format-Table
