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

#Set the module path from the Script Root
$ModulePath = $PSScriptRoot

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

#Dot Source the files
foreach ($FunctionType in @('Private', 'Public')) {
    $Path = Join-Path -Path $ModulePath -ChildPath ('{0}\*.ps1' -f $FunctionType)
    if (Test-Path -Path $Path) {
        Get-ChildItem -Path $Path -Recurse | ForEach-Object -Process { . $_.FullName }
    }
}

#Create the ermetic reports directory
if (-not (Test-Path -Path "$Env:HOMEPATH\Documents\ErmeticReports")) {
    New-Item -Path "$Env:HOMEPATH\Documents\ErmeticReports" -ItemType Directory
}

#Set global module variables
$global:Token = $null
$global:Uri = $null
$global:filePath = "$Env:HOMEPATH\Documents\ErmeticReports"

#Get the Ermetic config from file if exits
Get-ErmeticConfig

#Export all public functions
Export-ModuleMember -Function $Public.Basename