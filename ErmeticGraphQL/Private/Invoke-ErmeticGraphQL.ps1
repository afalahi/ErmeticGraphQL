function Invoke-ErmeticGraphQL {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Query,
    [Parameter(Mandatory = $true)][string]$Uri,
    [Parameter(Mandatory = $true)][string]$Token
  )
  function Compress-String([string]$InputString) {
    $output = ([String]::Join(" ", ($InputString.Split("`n")))).Trim()
    return $output
  }
  [string]$cleanQuery = Compress-String -InputString $Query
  [HashTable]$headers = @{
    Authorization  = "Bearer $($Token)"
    'Content-Type' = "application/json"
  }
  $jsonRequestObject = [ordered]@{ }
  $jsonRequestObject.Add("query", $cleanQuery)

  [string]$serializedQuery = ""
  try {
    if ($psMajorVersion -gt 5) {
      $serializedQuery = $jsonRequestObject | ConvertTo-Json -Depth 100 -Compress -EscapeHandling "Default" -ErrorAction Stop -WarningAction SilentlyContinue
    }
    else {
      $serializedQuery = $jsonRequestObject | ConvertTo-Json -Depth 100 -Compress -ErrorAction Stop -WarningAction SilentlyContinue
    }
  }
  catch {
    Write-Error -Exception $_.Exception -Category InvalidResult -ErrorAction Stop
  }
  [HashTable]$Params = @{
    'Uri'             = $Uri
    'Method'          = 'Post'
    'Body'            = $serializedQuery
    'ContentType'     = 'application/json'
    'UseBasicParsing' = $true
  }
  $Params.Add("Headers", $headers)
  try {
    [object]$response = Invoke-WebRequest @Params -ErrorAction Stop | ConvertFrom-Json
  }
  catch {
    Write-Error -Exception $_.Exception -Category InvalidOperation -ErrorAction Stop
    # exit
  }
  try {
    return $response
  }
  catch {
    Write-Error -Exception $_.Exception -Category InvalidResult -ErrorAction Stop
  }
}