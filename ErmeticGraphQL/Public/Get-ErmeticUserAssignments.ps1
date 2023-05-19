function Get-ErmeticUserAssignments {
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

  if ($CSV) {
    try {
      $csvFilePath = "users.csv"
      $csvFileWriter = [System.IO.File]::CreateText($csvFilePath)
      try {
        Write-Host $accessReport[0].Keys
        $csvFileWriter.WriteLine(($accessReport[0].Keys) -join ",")
      } catch [System.IO.IOException] {
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
            $csvFileWriter.WriteLine("$account,$accountId,$($users[$i]),$($role[$i]),$($accessType[$i]),$($accountPath[$i])")
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
  }


  if ($JSON) {
    $jsonFilePath = "users.json"
    $accessReport = @()
    [HashTable]$userRole = @{
      UserId     = $null
      Role       = $null
      AccessType = $null
      FolderPath = $null
    }

    foreach ($account in $awsAccounts) {
      [HashTable]$obj = [ordered]@{
        "AccountName" = $account.Name
        "AccountId"   = $account.Id
        "Users"       = @()
      }

      foreach ($user in $users) {
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

      $accessReport += $obj
    }
    $jsonContent = ConvertTo-Json -InputObject $accessReport -Depth 100

    try {
      $jsonContent | Out-File -FilePath $jsonFilePath -Encoding UTF8
    } catch {
      throw "Error writing to file $($jsonFilePath): $($_.Exception.Message)"
    }
  }
}