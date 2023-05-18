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

function Invoke-ErmeticRequest {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ScriptBlock]$Query
  )

  $response = Invoke-ErmeticGraphQL -Query $Query
  $resource = ""
  foreach ($key in $response['data'].Keys) {
    $resource = $key
  }
  # Prepare pagination variables
  [object[]]$results = $response['data'][$resource]['nodes']
  [boolean]$hasNextPage = $response['data'][$resource]['pageInfo']['hasNextPage']
  [string]$currentCursor = $response['data'][$resource]['pageInfo']['endCursor']
  while ($hasNextPage -eq $true) {
    $query = Use-ErmeticAwsAccountQuery -CurrentCursor $CurrentCursor
    $data = Invoke-ErmeticGraphQL -Query $query
    $awsAccounts += $data.data.AwsAccounts.nodes
    $CurrentCursor = '"' + $data.data.AwsAccounts.pageInfo.endCursor + '"'
    $hasNextPage = $data.data.AwsAccounts.pageInfo.hasNextPage
  }
}