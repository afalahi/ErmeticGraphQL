# $jsonData = Get-Content -Raw -Path 'data.json' | ConvertFrom-Json

# $outputFile = 'output.csv'

# # Create an empty list to hold the rows of data
# $rows = @()

# # Loop through each entry in the JSON data
# foreach ($entry in $jsonData) {
#     $account = $entry.account
#     $accountId = $entry.accountId
#     $users = $entry.Users
#     $role = $entry.Role
#     $accessType = $entry.AccessType

#     # Loop through each user, role, and access type and add a row for each one
#     for ($i = 0; $i -lt $users.Count; $i++) {
#         $rows += [pscustomobject]@{
#             account = $account
#             accountId = $accountId
#             Users = $users[$i]
#             Role = $role[$i]
#             AccessType = $accessType[$i]
#         }
#     }
# }

# # Export the data to a CSV file
# $rows | Export-Csv -Path $outputFile -NoTypeInformation

function Get-ErmeticUserAssignments {
    [CmdletBinding()]
    param (
        [switch] $CSV,
        [switch] $JSON
    )

    function Get-ErmeticAwsFolderPath {
        param (
            [array] $folders,
            [string] $awsFolderId
        )

        foreach ($item in $folders) {
            if ($item.Id -eq $awsFolderId) {
                $parentId = $item.ParentScopeId
                if ($null -eq $parentId) {
                    return $item.Name
                }
                else {
                    $parentPath = Get-ErmeticAwsFolderPath -folders $folders -awsFolderId $parentId
                    return "$parentPath/$($item.Name)"
                }
            }
        }
        return $null
    }

    $users = Get-ErmeticUsers
    $awsAccounts = Get-ErmeticAwsAccounts
    $folders = Get-ErmeticFolders

    $accessReport = @()
    foreach ($account in $awsAccounts) {
        $obj = @{
            "account"   = $account.Name
            "accountId" = $account.Id
        }
        $userRole = @()
        $userName = @()
        $accessType = @()
        $path = @()

        foreach ($user in $users) {
            if ($account.Id -eq $user.ScopeId) {
                $userName += $user.UserId
                $userRole += $user.Role
                $accessType += "Direct"
                $path += Get-ErmeticAwsFolderPath -folders $folders -awsFolderId $account.ParentScopeId
            }
            if ($null -eq $user.ScopeId) {
                $userName += $user.UserId
                $userRole += $user.Role
                $accessType += "Organization"
                $path += Get-ErmeticAwsFolderPath -folders $folders -awsFolderId $account.ParentScopeId
            }
            foreach ($folder in $folders) {
                if ($folder.Id -eq $user.ScopeId -and $folder.Id -eq $account.ParentScopeId) {
                    $userName += $user.UserId
                    $userRole += $user.Role
                    $accessType += $folder.Name
                    $path += Get-ErmeticAwsFolderPath -folders $folders -awsFolderId $account.ParentScopeId
                }
            }
        }

        $obj.Users = $userName
        $obj.Role = $userRole
        $obj.AccessType = $accessType
        $obj.AccountPath = $path
        $accessReport += $obj
    }

    if ($csvFile) {
        try {
            $csvFilePath = "users.csv"
            $csvFileWriter = [System.IO.File]::CreateText($csvFilePath)
            $csvWriter = [System.IO.StreamWriter]::new($csvFileWriter)
            try {
                $csvWriter.WriteLine(($accessReport[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) -join ",")
            }
            catch [System.IO.IOException] {
                throw "Error writing to file $($csvFilePath): $($_.Exception.Message)"
            }

            foreach ($entry in $accessReport) {
                $account = $entry.account
                $accountId = $entry.accountId
                $users = $entry.Users
                $role = $entry.Role
                $accessType = $entry.AccessType
                $accountPath = $entry.AccountPath

                try {
                    for ($i = 0; $i -lt $users.Count; $i++) {
                        $csvWriter.WriteLine("$account,$accountId,$($users[$i]),$($role[$i]),$($accessType[$i]),$($accountPath[$i])")
                    }
                }
                catch [System.IO.IOException] {
                    throw "Error writing to file $($csvFilePath): $($_.Exception.Message)"
                }
            }

            $csvWriter.Close()
            $csvFileWriter.Close()
        }
        catch [System.IO.FileNotFoundException] {
            throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
        }
        catch [System.UnauthorizedAccessException] {
            throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
        }
        catch [System.IO.IOException] {
            throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
        }
    }

    if ($jsonFile) {
        $jsonFilePath = "users.json"
        $jsonContent = ConvertTo-Json -InputObject $users

        try {
            $jsonContent | Out-File -FilePath $jsonFilePath -Encoding UTF8
        }
        catch {
            throw "Error writing to file $($jsonFilePath): $($_.Exception.Message)"
        }
    }

    return $accessReport
}