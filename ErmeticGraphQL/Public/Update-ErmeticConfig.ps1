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
  <#
    .SYNOPSIS
    Updates the Ermetic module configurations with new values for the token and URI.
    
    .DESCRIPTION
    The Update-ErmeticConfig cmdlet is used to update the configuration settings for the Ermetic module.
    You can provide new values for the API token and URI to be used for subsequent API calls.

    .PARAMETER Token
    The new value for the Ermetic API token. If not provided, the existing token value will be used.

    .PARAMETER Uri
    The new value for the Ermetic API URI. If not provided, the existing URI value will be used.

    .EXAMPLE
    Update-ErmeticConfig -Token "your_new_token"

    Description
    -------------
    Updates the Ermetic module configuration with a new API token.

    .EXAMPLE
    Update-ErmeticConfig -Uri "https://api.ermetic.com/v2"

    Description
    -------------
    Updates the Ermetic module configuration with a new API URI.

    .EXAMPLE
    Update-ErmeticConfig -Token "your_new_token" -Uri "https://api.ermetic.com/v2"

    Description
    -------------
    Updates both the API token and URI in the Ermetic module configuration.

    #>
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