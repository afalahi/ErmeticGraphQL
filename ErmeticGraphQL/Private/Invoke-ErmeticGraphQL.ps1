function Invoke-ErmeticGraphQL {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ScriptBlock]$Query,
    [Parameter(Mandatory = $true)][string]$Uri,
    [Parameter(Mandatory = $true)][string]$Token
  )
  # function Compress-String([string]$InputString) {
  #   $output = ([String]::Join(" ", ($InputString.Split("`n")))).Trim()
  #   return $output
  # }
  # [string]$cleanQuery = Compress-String -InputString $Query
  # $jsonRequestObject = [ordered]@{ }
  # $jsonRequestObject.Add("query", $cleanQuery)

  # [string]$serializedQuery = ""
  # try {
  #   if ($psMajorVersion -gt 5) {
  #     $serializedQuery = $jsonRequestObject | ConvertTo-Json -Depth 100 -Compress -EscapeHandling "Default" -ErrorAction Stop -WarningAction SilentlyContinue
  #   }
  #   else {
  #     $serializedQuery = $jsonRequestObject | ConvertTo-Json -Depth 100 -Compress -ErrorAction Stop -WarningAction SilentlyContinue
  #   }
  # }
  # catch {
  #   Write-Error -Exception $_.Exception -Category InvalidResult -ErrorAction Stop
  # }
  $query = & $Query -CurrentCursor "null"
  $serializedQuery = Format-GraphQLQuery -InputString $query
  [HashTable]$headers = @{
    Authorization  = "Bearer $($Token)"
    'Content-Type' = "application/json"
  }
  [HashTable]$Params = @{
    'Uri'             = $Uri
    'Method'          = 'Post'
    'ContentType'     = 'application/json'
    'UseBasicParsing' = $true
  }
  $Params.Add("Headers", $headers)
  try {
    [object]$response = Invoke-WebRequest @Params -Body $serializedQuery -ErrorAction Stop | ConvertFrom-Json

    $resource = ""
    foreach ($key in $data['data'].Keys) {
      $resource = $key
    }
    # Prepare pagination variables
    $results = $response['data'][$resource]['nodes']
    $hasNextPage = $response['data'][$resource]['pageInfo']['hasNextPage']
    $currentCursor = '"' + $response['data'][$resource]['pageInfo']['endCursor'] + '"'
    while ($hasNextPage -eq $true) {
      $query = & $Query -CurrentCursor $currentCursor
      $serializedQuery = Format-GraphQLQuery -InputString $query
      $response = Invoke-WebRequest @Params -Body $serializedQuery -ErrorAction Stop | ConvertFrom-Json
      $results += $response['data'][$resource]['nodes']
      $hasNextPage = $response['data'][$resource]['pageInfo']['hasNextPage']
      $currentCursor = '"' + $response['data'][$resource]['pageInfo']['endCursor'] + '"'
    }
  }
  catch {
    Write-Error -Exception $_.Exception -Category InvalidOperation -ErrorAction Stop
    # exit
  }
  try {
    return $results
  }
  catch {
    Write-Error -Exception $_.Exception -Category InvalidResult -ErrorAction Stop
  }
}