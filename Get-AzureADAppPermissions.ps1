#Connect
Connect-AzureAD

#Create array we will use to gather data into.
[array]$Report = $null

#Get all service principles
$SPs = Get-AzureADServicePrincipal -All $true


#Get Application Permissions (access without a user)
Foreach ($SP in $SPs) {
    [array]$AppRoles = Get-AzureADServiceAppRoleAssignedTo -ObjectId $SP.ObjectID

    Foreach ($AppRole in $AppRoles) {
    
        #if the application has a secret or a certificate.. which means it can actualy use the permissions without a user being present
        $Resource = Get-AzureADObjectByObjectId -ObjectIds $AppRole.ResourceId
        $Permission = $Resource.AppRoles | Where-Object { $_.id -eq $AppRole.Id }
        $Application = Get-AzureADApplication -All $True | Where-Object { $_.AppId -eq $SP.AppId }

        If ($Application) {

            $Row = New-Object PSObject
            $Row | add-member Noteproperty App                          $Application.DisplayName
            $Row | add-member Noteproperty Resource                     $AppRole.ResourceDisplayName
            $Row | add-member Noteproperty Permission                   $Permission.Value
            $Row | add-member Noteproperty SecretEndDate                $Application.PasswordCredentials.EndDate
            $Row | add-member Noteproperty CertEndDate                  $Application.KeyCredentials.EndDate
            $Row | add-member Noteproperty CreatedDate                  $AppRole.CreationTimestamp
            $Report += $Row
        }
    }
}

#Get Application Roles & Groups (access without a user)
Foreach ($SP in $SPs) {
      
    #if the application has a secret or a certificate.. which means it can actualy use the permissions without a user being present
    $Application = Get-AzureADApplication -All $True | Where-Object { $_.AppId -eq $SP.AppId }
    
    If ($Application) {

        $AppMemberships = Get-AzureADServicePrincipalMembership -ObjectId $SP.ObjectID
    
        Foreach ($AppMembership in $AppMemberships) {
    
            $Row = New-Object PSObject
            $Row | add-member Noteproperty App                          $Application.DisplayName
            $Row | add-member Noteproperty Resource                     $AppMembership.ObjectType
            $Row | add-member Noteproperty Permission                   $AppMembership.DisplayName
            $Row | add-member Noteproperty SecretEndDate                $Application.PasswordCredentials.EndDate
            $Row | add-member Noteproperty CertEndDate                  $Application.KeyCredentials.EndDate
            $Row | add-member Noteproperty CreatedDate                  $AppRole.CreationTimestamp
            $Report += $Row
        }
    }
}

$Report 
$Report | Out-File .\NotFilterd3.txt



