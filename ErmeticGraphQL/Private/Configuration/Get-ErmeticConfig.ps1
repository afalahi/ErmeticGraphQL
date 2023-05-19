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

function Get-ErmeticConfig {
  # Construct the configuration file path in the user's home directory
  $configPath = Join-Path $HOME -ChildPath 'ErmeticGraphQL\Configurations\ErmeticConfig.xml'

  # Check if the configuration file exists
  if (Test-Path $configPath) {
    # Load the secure configuration file
    $config = Import-Clixml -Path $configPath

    # Decrypt the secure strings
    $token = $config.Token
    $uri = $config.Uri

    # Assign the decrypted values to module-level variables
    $global:Token = $token
    $global:Uri = $uri
  } else {
    Write-Warning "Configuration file not found. Use Set-ModuleConfig to set the configurations."
  }
}