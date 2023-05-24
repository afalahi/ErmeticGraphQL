function Get-ErmeticAwsAccounts {
  <#
.SYNOPSIS
Retrieves AWS accounts from Ermetic.

.DESCRIPTION
The Get-ErmeticAwsAccounts cmdlet retrieves AWS accounts from Ermetic. It can filter the accounts based on their status (Valid or Invalid) and export the results to a CSV file if specified.

.PARAMETER CSV
Specifies whether to export the retrieved data to a CSV file. If specified, a CSV file will be created with the AWS account information.

.PARAMETER Filter
Specifies the filter to apply to the AWS accounts. The valid values are "Valid", "Invalid", and "All". The default value is "All".

.EXAMPLE
Get-ErmeticAwsAccounts -CSV -Filter "Valid"

Description
-------------
Retrieves the valid AWS accounts from Ermetic and exports the account information to a CSV file.

.EXAMPLE
Get-ErmeticAwsAccounts -Filter "Invalid"

Description
-------------
Retrieves the invalid AWS accounts from Ermetic.

#>


  [CmdletBinding()]  
  param (
    [switch]$CSV,
    [ValidateSet("Valid", "Invalid")]
    [string]$Filter = 'All'
  )
  $awsAccounts = Invoke-ErmeticGraphQL -Query Use-ErmeticAwsAccountQuery
  function FilterResults([string]$Filter) {
    switch ($Filter) {
      "Invalid" { 
        $awsAccounts = $awsAccounts.Where({ [string]$_.Status -ne 'Valid' })
        return $(if ($awsAccounts.Count -gt 0) { $awsAccounts } else { 'All Accounts Connected' })
      }
      "Valid" {
        $awsAccounts = $awsAccounts.Where({ [string]$_.Status -eq 'Valid' })
        # Removes issues property from valid accounts
        $awsAccounts.ForEach({ $_.PSObject.properties.remove("Issues") })
        return $awsAccounts
      }
      Default { return $awsAccounts }
    }
  }
  $results = FilterResults -Filter $Filter
  if ($CSV) {
    if ($results.GetType().Name -eq "String") {
      return $results
    }
    $fileName = "$global:filePath\AwsAccounts-$Filter-$(Get-Date -Format "yyyy-MM-dd").csv"
    $results = $results | Export-Csv -Path $fileName -NoTypeInformation -Encoding utf8 -ErrorAction Stop
    Write-Host "Wrote data to $fileName"
  } else {
    return $results
  }
}