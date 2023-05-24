# Copyright 2023 ali.falahi@ermetic.com
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
Add-Type -AssemblyName "System.Net"
Add-Type -AssemblyName "System.Net.Http"
function Get-ErmeticUsers {
  [CmdletBinding()]
  $query = Use-ErmeticUsersQuery
  $serializedQuery = Format-GraphQLQuery -InputString $query
  $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:Token))
  [HashTable]$headers = @{
    Authorization  = "Bearer $token"
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
    $users = $response.data.UserRoleAssignments
    $token = $null
    return $users
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