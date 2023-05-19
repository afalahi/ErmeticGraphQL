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
using namespace System.Net
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
    return $users
  } catch [System.Net.Http.HttpRequestException] {
    $webException = $_.Exception
    $statusCode = $webException.Response.StatusCode
    if ($statusCode -eq [HttpStatusCode]::Unauthorized) {
      Write-Error "Web request failed with HTTP $statusCode $($_.Exception.Message)" -ErrorAction Stop
    }
    $responseBody = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Error "Web request failed with HTTP $statusCode $($_.Exception.Message) - $($responseBody.errors.message)" -ErrorAction Stop
  } catch [System.Net.WebException] {
    $errorMessage = $webException.Message
    Write-Error "Web request failed: $errorMessage" -ErrorAction Stop
  } catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)" -ErrorAction Stop
  }
}