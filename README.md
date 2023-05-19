<!--
 Copyright 2023 ali.falahi@ermetic.com

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# ErmeticGraphQL

ErmeticGraphQL is a PowerShell module that provides a set of cmdlets for interacting with the Ermetic GraphQL API. It allows you to automate various operations related to user role assignments, folders, and more in the Ermetic platform.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Available Cmdlets](#available-cmdlets)
  - [Set-ErmeticConfig](#set-ermeticconfig)
  - [Update-ErmeticConfig](#update-ermeticconfig)
  - [Get-ErmeticAwsAccounts](#get-ermeticawsaccounts)
  - [Get-ErmeticUserAssignments](#get-ermeticuserassignments)

## Introduction

The ErmeticGraphQL PowerShell module provides cmdlets for interacting with ErmeticGraphQL. It allows you to retrieve information about Cloud Providers, Findings, and user assignments. You can also configure and update the Ermetic connection settings.

## Installation

You can install the ErmeticGraphQL module from the PowerShell Gallery using the following command:

```powershell
Install-Module -Name ErmeticGraphQL
```

## Prerequisites

- PowerShell 5.1 or later.
- Ermetic API credentials and access to the Ermetic platform.

## Getting Started

1. Import the ErmeticGraphQL module:

   ```powershell
   Import-Module -Name ErmeticGraphQL
   ```

2. Set up the module configuration with your Ermetic API token and URI:

   ```powershell
   Set-ErmeticConfig -Token "your_api_token" -Uri "https://api.ermetic.com"
   ```

   Replace `"your_api_token"` with your actual Ermetic API token.

3. Start using the ErmeticGraphQL cmdlets to interact with the Ermetic platform.

## Available Cmdlets

The ErmeticGraphQL module provides the following cmdlets:

- `Set-ErmeticConfig`: Sets the Ermetic module configurations with new values for the Token and URI.
- `Update-ErmeticConfig`: Updates the Ermetic module configurations with new values for the token and URI.
- `Get-ErmeticAwsAccounts`: Retrieves `All`, `Valid`, or `Invalid` AWS Account and their connection status.
- `Get-ErmeticUsersAssignments`: Retrieves user assignments for all users in the Ermetic platform.

### Set-ErmeticConfig

Connects to the ErmeticGraphQL API with the provided access token.

```powershell
Set-ErmeticConfig -Token 'your-access-token' -Uri "https://us.app.ermetic.com/api/graph"
```

## Parameters

### -Token

```yaml
Type: string
Parameter Sets: (All)
Aliases:

Require: True
Position: Named
Default Value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri

Filters the AWS accounts based on their status.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### Update-ErmeticConfig

Updates the Ermetic module configurations with new values for the token and URI.

```powershell
# Only update the token
Update-ErmeticConfig -Token 'new-token'

# Only update the url
Update-ErmeticConfig -Uri 'https://new-uri.com'

# Update both token and url
Update-ErmeticConfig -Token 'new-token' -Uri 'https://new-uri.com'

```

## Parameters

### -Token

```yaml
Type: string
Parameter Sets: (All)
Aliases:

Require: False
Position: Named
Default Value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri

Filters the AWS accounts based on their status.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### Get-ErmeticAwsAccounts

Retrieves `All`, `Valid`, or `Invalid` AWS Account and their connection status. This Cmdlet returns a custom object unless specified with `-NoOutPut` Parameter

```powershell
# Retrieve all AWS accounts
Get-ErmeticAwsAccounts

# Retrieve only valid AWS accounts
Get-ErmeticAwsAccounts -Filter 'Valid'

# Retrieve only invalid AWS accounts
Get-ErmeticAwsAccounts -Filter 'Invalid'

# Export the results to a CSV file
Get-ErmeticAwsAccounts -CSV -Filter 'Valid'

```

## Parameters

### -CSV

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Require: False
Position: Named
Default Value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter

Filters the AWS accounts based on their status.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accepted Values: All, Valid, Invalid
Accept pipeline input: False
Accept wildcard characters: False
```

### Get-ErmeticUserAssignments

Retrieves all user assignments from Ermetic in csv or json format, or returns `PSCustomObject`.

```ps
# Retrieve user assignments and return as PSCustomObject
Get-ErmeticUserAssignments

# Retrieve user assignments and export the results to a CSV file
Get-ErmeticUserAssignments -CSV

# Retrieve user assignments and export the results to a JSON file
Get-ErmeticUserAssignments -JSON

```

## Parameters

### -CSV

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JSON

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

You can find detailed usage examples and parameters for each cmdlet in their respective help documentation. Use the `Get-Help` cmdlet followed by the cmdlet name to view the help documentation.

## Contributing

Contributions to the ErmeticGraphQL module are welcome! If you encounter any issues, have suggestions, or want to contribute improvements, please create an issue or submit a pull request on the [GitHub repository](https://github.com/afalahi/ErmeticGraphQL).

## License

This project is licensed under the [Apache License](LICENSE).

## Acknowledgements

The ErmeticGraphQL module is developed and maintained by [Ali Falahi].

---
