#run windows query (Windows Management Instrumentation (WMI))
Get-CimInstance -Query 'Select * from Win32_BIOS'

#get all approved verb list sort by verb name
Get-Verb | Sort-Object -Property Verb

#function
#==========
function Check-Version{
    if(($PSVersionTable.PSVersion.Major) -lt  7)
    {
     Write-Warning 'Not compatible'
    }
    else
    {
        $PSVersionTable.PSVersion
    }
    
}

#Invoke function
Check-Version

#Function with Parameter
function Check-VersionGiven{
    param(
       [stirng] $version
        )

        $PSVersion = $PSVersionTable.PSVersion.Major
    if($PSVersion -lt $version)
    {
        Write-Output "$PSVersion Lower than $version"
    }
    else
    {
        Write-host 'Compatible'
    }    
}

#invoke 
Check-VersionGiven -version 7

#Get parameters of a function
(Get-Command -Name Check-VersionGiven).Parameters.Keys

#Array Parameter
#Check Service Health
function Check-ServiceHealth {
    [CmdletBinding()] # To turn function into a advance function (SupportsShouldProcess adds WhatIf and Confirm parameters.) #SupportShouldProcess
    param(
    [string[]] $Services
    )

    foreach($service in $Services)
    {
               # First we create the request.
            $HTTP_Request = [System.Net.WebRequest]::Create($service)

            # We then get a response from the site.
            $HTTP_Response = $HTTP_Request.GetResponse()

            # We then get the HTTP code as an integer.
            $HTTP_Status = [int]$HTTP_Response.StatusCode

            If ($HTTP_Status -eq 200) {
                
                @{
                    Attempt = $HTTP_Response.LastModified;
                    Response = $HTTP_Response.ResponseUri;
                    Status = $HTTP_Response.StatusDescription;
                    Result = "Pass"
                 }
            }
            Else {
                write-verbose "attension"
                Write-Error "The Site may be down, please check!"
            }

            # Finally, we clean up the http request by closing it.
            If ($HTTP_Response -eq $null) { } 
            Else { $HTTP_Response.Close() }
        }
}

#check health for these computers
Check-ServiceHealth -Services http://service/index123.html, http://service/index123456.html -Verbose


#get help with example
get-help New-Module -examples

#Function Param
function Print-Name
{
    [CmdletBinding()] #To turn function into a advance function     
    param([string] $Name)
    Write-Verbose "printing name.." 
    Write-Output "Hello $Name" #-forgroundcolor green
    Write-Verbose "Name Printed"
}

#to get function parameters
(get-command -Name Print-name).Parameters.Keys

#Function support should process -- whatif and confirm
function Delete-File()
{
    [CmdletBinding(SupportsShouldProcess)] #(SupportsShouldProcess adds WhatIf and Confirm parameters.)
    param([string] $FileToDelete)
    
    Remove-Item $FileToDelete
    
}

#run the function in whatif mode
Delete-File -FileToDelete C:\Temp\delete.txt -WhatIf
#run the function without whatif mode
Delete-File -FileToDelete C:\Temp\delete.txt


#Run function with Confirm parameter
Delete-File -FileToDelete C:\Temp\delete.txt -Confirm

#Mandatory & Optional Parameter
function Create-LogFile()
{
    param(    
    [string] $LogPath = "C:\temp",
    [Parameter(Mandatory)]
    [string] $LogFileName
    
    )
    
    New-Item -Path $LogPath -Name $LogFileName -ItemType "file" 
}


#invoke
Create-LogFile -LogFileName "delete.txt"

#Pipeline input 
function Test-MyNetwork {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

#invoke method
Test-MyNetwork -ComputerName stage01, abc, stage02, db1 #-ErrorAction Stop

#Supply parameter from pipeline
@('stage01','stage02') | Test-MyNetwork



#Comment help
function Add-Extension
{
    param ([string]$Name,[string]$Extension = "txt")
    $name = $name + "." + $extension
    $name

    <#
        .SYNOPSIS
        Adds a file name extension to a supplied name.

        .DESCRIPTION
        Adds a file name extension to a supplied name.
        Takes any strings for the file name or extension.

        .PARAMETER Name
        Specifies the file name.

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>
}

#get command based help
get-help add-extension -full

#To get imported Module
Get-Module

#get List of all availale Modules
 Get-Module -ListAvailable


#Import Module
Import-Module PowerShellGet


#Navigate to PS Home directory
cd $PSHome

#Default folder for Modules 
CD Modules

#Get All Modules from Default module folder
Dir | More

#Module Location for all users
cd $Env:ProgramFiles\WindowsPowerShell\Modules

#Module Location for current user
cd $Home\Documents\WindowsPowerShell\Modules

#Copy psm1 file to ProgramFiles\WindowsPowerShell\Modules
#Import the module
Import-Module GetServiceHealth.psm1

#Check module is loaded
Get-Module

#Invoke method from module
Check-ServiceHealth -Services http://service/index123.html, http://service/index123456.html -LogPath c:\temp -Verbose
#call method
#Check-ServiceHealth -Services http://service/index123.html, http://service/index123456.html -LogPath c:\temp -Verbose

#To create Module Manifest
New-ModuleManifest
#Give path (where the module is saved) along with file name with ext .psd1

#To Test Module Manifest
#Locate the module directory
cd "C:\Program Files\WindowsPowerShell\Modules\CheckServiceHealth"
#Test
Test-ModuleManifest -Path .\CheckServiceHealth.psd1

#Download Analyzer module
Install-Module -Name PSScriptAnalyzer

#Run analyzer
Invoke-ScriptAnalyzer -Path "C:\Program Files\WindowsPowerShell\Modules\CheckServiceHealth\CheckServiceHealth.psm1"

#Key:
$PSGalleryKey = "xxxxxxxxxxxxxx"
#Publish the Module (use PS7. For me, PS5 was throwing weird error)
Publish-Module -Path "C:\Program Files\WindowsPowerShell\Modules\CheckServiceHealth\" -NuGetApiKey $PSGalleryKey -WhatIf -Verbose

$PSHome
