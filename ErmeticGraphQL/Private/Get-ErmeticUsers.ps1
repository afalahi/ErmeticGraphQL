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

function Get-ErmeticUsers {
    [CmdletBinding()]
    param (
        [string] $Url,
        [string] $Token
    )

    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
    $query = Use-ErmeticUsersQuery
    Write-Host $query
    try {
        $response = Invoke-RestMethod -Uri $Url -Headers $headers -Method Post -Body @{
            query = Use-ErmeticUsersQuery
        } -ErrorAction Stop
        $users = $response.data.UserRoleAssignments
        return $users
    }
    catch [System.Net.HttpStatusCodeException] {
        $errorMessage = $_.Exception.Response.StatusDescription
        throw "UsersQueryError: $errorMessage"
    }
    catch [System.Net.WebException] {
        $errorMessage = $_.Exception.Message
        throw "UserRequestError: $errorMessage"
    }
}