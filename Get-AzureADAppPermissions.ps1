Connect-AzureAD

$SPs = Get-AzureADServicePrincipal -All $true 
[array]$AppRoles = $null
Foreach ($SP in $SPs) {
    $AppRoles += Get-AzureADServiceAppRoleAssignedTo -ObjectId $SP.ObjectID
}

[array]$Report = $null

Foreach ($AppRole in $AppRoles) {

    $Resource = Get-AzureADObjectByObjectId -ObjectIds $AppRole.ResourceId
    $Permission = $Resource.AppRoles | Where-Object {$_.id -eq $AppRole.Id}
    $Principal = Get-AzureADObjectByObjectId -ObjectIds $AppRole.PrincipalId
    $Application = Get-AzureADApplication -All $True | Where-Object {$_.AppId -eq $Principal.AppId}
    
    $Row = New-Object PSObject
    $Row | add-member Noteproperty App                          $AppRole.PrincipalDisplayName
    $Row | add-member Noteproperty Resource                     $AppRole.ResourceDisplayName
    $Row | add-member Noteproperty Permission                   $Permission.Value
    $Row | add-member Noteproperty SecretEndDate                $Application.PasswordCredentials.EndDate
    $Row | add-member Noteproperty CertEndDate                  $Application.KeyCredentials.EndDate
    $Row | add-member Noteproperty CreatedDate                  $AppRole.CreationTimestamp
    $Report += $Row
}

$Report | Select-Object App, Resource, Permission, SecretEndDate, CertEndDate, CreatedDate | Sort-Object Resource, Permission | Format-Table
