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
    Write-Verbose -Message "Processing Application Permissions (access without a user) for $($SP.DisplayName)"
    [array]$AppRoles = Get-AzureADServiceAppRoleAssignedTo -ObjectId $SP.ObjectID

    Foreach ($AppRole in $AppRoles) {
    
        #if the application has a secret or a certificate.. which means it can actually use the permissions without a user being present
        $Resource = Get-AzureADObjectByObjectId -ObjectIds $AppRole.ResourceId
        $Permission = $Resource.AppRoles | Where-Object { $_.id -eq $AppRole.Id }
        $Application = Get-AzureADApplication -All $True | Where-Object { $_.AppId -eq $SP.AppId }

        If ($Application) {

            $Row = New-Object PSObject
            $Row | Add-Member NoteProperty App                          $Application.DisplayName
            $Row | Add-Member NoteProperty Resource                     $AppRole.ResourceDisplayName
            $Row | Add-Member NoteProperty Permission                   $Permission.Value
            $Row | Add-Member NoteProperty SecretEndDate                $Application.PasswordCredentials.EndDate
            $Row | Add-Member NoteProperty CertEndDate                  $Application.KeyCredentials.EndDate
            $Row | Add-Member NoteProperty CreatedDate                  $AppRole.CreationTimestamp
            $Report += $Row
        }
    }
}

#Get Application Roles & Groups (access without a user)
Foreach ($SP in $SPs) {
    Write-Verbose -Message "Processing Application Roles & Groups (access without a user) for $($SP.DisplayName)"

    #if the application has a secret or a certificate.. which means it can actually use the permissions without a user being present
    $Application = Get-AzureADApplication -All $True | Where-Object { $_.AppId -eq $SP.AppId }
    
    If ($Application) {

        $AppMemberships = Get-AzureADServicePrincipalMembership -ObjectId $SP.ObjectID
    
        Foreach ($AppMembership in $AppMemberships) {
    
            $Row = New-Object PSObject
            $Row | Add-Member NoteProperty App                          $Application.DisplayName
            $Row | Add-Member NoteProperty Resource                     $AppMembership.ObjectType
            $Row | Add-Member NoteProperty Permission                   $AppMembership.DisplayName
            $Row | Add-Member NoteProperty SecretEndDate                $Application.PasswordCredentials.EndDate
            $Row | Add-Member NoteProperty CertEndDate                  $Application.KeyCredentials.EndDate
            $Row | Add-Member NoteProperty CreatedDate                  $AppRole.CreationTimestamp
            $Report += $Row
        }
    }
}

$Report 

