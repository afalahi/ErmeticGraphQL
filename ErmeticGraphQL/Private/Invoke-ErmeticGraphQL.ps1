Add-Type -AssemblyName "System.Net"
Add-Type -AssemblyName "System.Net.Http"
function Invoke-ErmeticGraphQL {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    $Query
  )
  $query = & $Query -CurrentCursor "null"
  $serializedQuery = Format-GraphQLQuery -InputString $query
  $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:Token))
  [HashTable]$headers = @{
    Authorization  = "Bearer $($token)"
    'Content-Type' = "application/json"
  }
  [HashTable]$Params = @{
    'Uri'             = $global:Uri
    'Method'          = 'Post'
    'ContentType'     = 'application/json'
    'UseBasicParsing' = $true
  }
  $Params.Add("Headers", $headers)
  try {
    [object]$response = Invoke-WebRequest @Params -Body $serializedQuery -ErrorAction Stop | ConvertFrom-Json
    $resource = $response.data | Get-Member -MemberType Properties | ForEach-Object {
      return $_.Name
    }
    $results = $response.data.$resource.nodes
    $hasNextPage = $response.data.$resource.pageInfo.hasNextPage
    $currentCursor = '"' + $response.data.$resource.pageInfo.endCursor + '"'
    while ($hasNextPage -eq $true) {
      $query = & $Query -CurrentCursor $currentCursor
      $serializedQuery = Format-GraphQLQuery -InputString $query
      $response = Invoke-WebRequest @Params -Body $serializedQuery -ErrorAction Stop | ConvertFrom-Json
      $results += $response.data.$resource.nodes
      $hasNextPage = $response.data.$resource.pageInfo.hasNextPage
      $currentCursor = '"' + $response.data.$resource.pageInfo.endCursor + '"'
    }
    $token = $null
    return $results
  } catch [System.Net.Http.HttpRequestException] {
    $token = $null
    $webException = $_.Exception
    $statusCode = $webException.Response.StatusCode
    if ($statusCode -eq "Unauthorized") {
      Write-Error "Web request failed with HTTP $statusCode $($_.Exception.Message)" -Category AuthenticationError -ErrorAction Stop
    }
    $responseBody = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Error "Web request failed with HTTP $statusCode $($_.Exception.Message) - $($responseBody.errors.message)" -ErrorAction Stop
  } catch [System.Net.WebException] {
    $token = $null
    $webException = $_.Exception
    $statusCode = $webException.Response.StatusCode
    $errorMessage = $_.Exception.Message
    if ($statusCode -eq "Unauthorized") {
      Write-Error "Web request failed: $errorMessage" -Category AuthenticationError -ErrorAction Stop
    }
    if ($statusCode -eq "BadRequest") {
      $streamReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $streamReader.BaseStream.Position = 0
      $streamReader.DiscardBufferedData()
      $responseBody = $streamReader.ReadToEnd() | ConvertFrom-Json
      Write-Error "Web request failed: $errorMessage - $($responseBody.errors.message)"  -Category InvalidOperation -ErrorAction Stop
    } else {
      Write-Error "Web request failed: $errorMessage" -ErrorAction Stop
    }
  } catch {
    $token = $null
    Write-Error "An unexpected error occurred: $($_.Exception.Message)" -Category InvalidOperation -ErrorAction Stop
  }
}