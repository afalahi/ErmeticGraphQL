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

function Format-GraphQLQuery([string]$InputString) {
  [string]$cleanQuery = ([String]::Join(" ", ($InputString.Split("`n")))).Trim()

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
  return $serializedQuery
}