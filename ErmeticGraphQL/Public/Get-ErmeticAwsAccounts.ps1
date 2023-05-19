function Get-ErmeticAwsAccounts {
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
  if ($CSV -eq $true) {
    if ($results.GetType().Name -eq "String") {
      return $results
    }
    $fileName = "AwsAccounts-$Filter.csv"
    $results = $results | Export-Csv -Path .\$fileName -NoTypeInformation -Encoding utf8
  }
  return $results
}