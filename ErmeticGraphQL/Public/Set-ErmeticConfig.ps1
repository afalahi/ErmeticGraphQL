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

function Set-ErmeticConfig {
    <#
.SYNOPSIS
Sets the configuration for the ErmeticGraphQL module.

.DESCRIPTION
The Set-ErmeticConfig cmdlet sets the configuration values for the ErmeticGraphQL module. It requires providing the Ermetic API token and URI. The provided token is securely stored in an XML configuration file, and the configuration values are set as global variables for the current PowerShell session.

.PARAMETER Token
The Ermetic API token to authenticate with the Ermetic platform.

.PARAMETER Uri
The URI of the Ermetic GraphQL endpoint.

.EXAMPLE
Set-ErmeticConfig -Token "YOUR_API_TOKEN" -Uri "https://example.ermetic.com/graphql"

Description
-------------
Sets the Ermetic configuration with the provided API token and URI. The configuration values are securely stored and made available for use within the ErmeticGraphQL module.

#>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Token,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri
    )

    # Convert sensitive values to secure strings
    $secureToken = ConvertTo-SecureString -String $Token -AsPlainText -Force
    $Token = "null"
    # Create a hashtable with the secure strings
    $config = @{
        Token = $secureToken
        Uri   = $Uri
    }

    # Export the hashtable as a secure configuration file
    # $configPath = "$PSScriptRoot\Configuration\ErmeticConfig.xml"
    $configPath = Join-Path $HOME -ChildPath 'ErmeticGraphQL\Configurations\ErmeticConfig.xml'
    # Create the directory if it doesn't exist
    $configDir = Split-Path -Path $configPath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    $config | Export-Clixml -Path $configPath -Force
    
    # Set the configuration as a global variable
    $global:Token = $secureToken
    $global:Uri = $Uri
}
