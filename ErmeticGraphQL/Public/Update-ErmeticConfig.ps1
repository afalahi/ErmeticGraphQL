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

function Update-ErmeticConfig {
  param (
    [Parameter(Mandatory = $false)]
    [string]$Token,

    [Parameter(Mandatory = $false)]
    [string]$Uri
  )

  # Get the existing configurations
  $existingToken = $global:Token
  $existingUri = $global:Uri

  # Update the configurations if new values are provided
  if ($Token) {
    $existingToken = $Token
  }
  if ($Uri) {
    $existingUri = $Uri
  }

  # Call the private function Set-ModuleConfigInternal to save the updated configurations
  Set-ErmeticConfig -Token $existingToken -Uri $existingUri
}