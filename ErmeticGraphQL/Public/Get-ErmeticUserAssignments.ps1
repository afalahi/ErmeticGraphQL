function Get-ErmeticUserAssignments {
  <#
.SYNOPSIS
Retrieves user assignments for Ermetic accounts.

.DESCRIPTION
The Get-ErmeticUserAssignments cmdlet retrieves user assignments for Ermetic accounts. It retrieves information about the accounts, users, roles, access types, and account paths. The retrieved data can be optionally exported to a CSV or JSON file.

.PARAMETER CSV
Specifies whether to export the retrieved data to a CSV file. If specified, a CSV file named "users.csv" will be created with the user assignments.

.PARAMETER JSON
Specifies whether to export the retrieved data to a JSON file. If specified, a JSON file named "users.json" will be created with the user assignments.

.EXAMPLE
Get-ErmeticUserAssignments -CSV

Description
-------------
Retrieves user assignments for Ermetic accounts and exports the data to a CSV file named "users.csv".

.EXAMPLE
Get-ErmeticUserAssignments -JSON

Description
-------------
Retrieves user assignments for Ermetic accounts and exports the data to a JSON file named "users.json".

#>
  [CmdletBinding()]
  param (
    [switch] $CSV,
    [switch] $JSON
  )

  $users = Get-ErmeticUsers
  $awsAccounts = Get-ErmeticAwsAccounts
  $folders = Get-ErmeticFolders

  $accessReport = @()
  foreach ($account in $awsAccounts) {
    # $usersArray = @()
    $obj = [ordered]@{
      AccountName = $account.Name
      AccountId   = $account.Id
      Users       = @()
    }

    foreach ($user in $users) {
      [HashTable]$userRole = @{
        UserId     = $null
        Role       = $null
        AccessType = $null
        FolderPath = $null
      }
      if ($account.Id -eq $user.ScopeId) {
        $userRole.UserId = $user.UserId
        $userRole.Role = $user.Role
        $userRole.AccessType = "Direct"
        $userRole.FolderPath = Get-ErmeticAwsFolderPath -Folders $folders -AwsFolderId $account.ParentScopeId
          
        $obj.Users += $userRole
      }

      if (-not $user.ScopeId) {
        $userRole.UserId = $user.UserId
        $userRole.Role = $user.Role
        $userRole.AccessType = "Organization"
        $userRole.FolderPath = Get-ErmeticAwsFolderPath -Folders $folders -AwsFolderId $account.ParentScopeId
          
        $obj.Users += $userRole
      }

      foreach ($folder in $folders) {
        if ($folder.Id -eq $user.ScopeId) {
          $userRole.UserId = $user.UserId
          $userRole.Role = $user.Role
          $userRole.AccessType = "Folder"
          $userRole.FolderPath = Get-ErmeticAwsFolderPath -Folders $folders -AwsFolderId $account.ParentScopeId
          
          $obj.Users += $userRole
        }
      }
    }
    # $obj.Users = $usersArray
    $accessReport += $obj
  }

  if ($CSV) {
    try {
      $csvFilePath = "users.csv"
      $csvFileWriter = [System.IO.File]::CreateText($csvFilePath)
      try {
        Write-Host @('AccountName', 'AccountID', 'UserId', 'Role', 'AccessType', 'FolderPath')
        $csvFileWriter.WriteLine(@('AccountName', 'AccountID', 'UserId', 'Role', 'AccessType', 'FolderPath') -join ",")
      } catch [System.IO.IOException] {
        throw "Error writing to file $($csvFilePath): $($_.Exception.Message)"
      }

      foreach ($entry in $accessReport) {
        $account = $entry.AccountName
        $accountId = $entry.AccountId
        $users = $entry.Users

        try {
          for ($i = 0; $i -lt $users.Count; $i++) {
            $csvFileWriter.WriteLine("$account,$accountId,$($users[$i].UserId),$($users[$i].Role),$($users[$i].AccessType),$($users[$i].FolderPath)")
          }
        } catch [System.IO.IOException] {
          throw "Error writing to file $($csvFilePath): $($_.Exception.Message)"
        }
      }

      $csvFileWriter.Close()
    } catch [System.IO.FileNotFoundException] {
      throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
    } catch [System.UnauthorizedAccessException] {
      throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
    } catch [System.IO.IOException] {
      throw "The file '$csvFilePath' is in use or we don't have access: $($_.Exception.Message)"
    }
  } elseif ($JSON) {
    $jsonFilePath = "users.json"
    $jsonContent = ConvertTo-Json -InputObject $accessReport -Depth 100

    try {
      $jsonContent | Out-File -FilePath $jsonFilePath -Encoding UTF8
    } catch {
      throw "Error writing to file $($jsonFilePath): $($_.Exception.Message)"
    }
  } else {
    return $accessReport
  }
}