function Check-ServiceHealth {
    [CmdletBinding()] # To turn function into a advance function (SupportsShouldProcess adds WhatIf and Confirm parameters.)
    param(
    [string[]] $Services,
    [string] $LogPath = "c:\temp"
    )

    foreach($service in $Services)
    {
            Write-Verbose "Connecting Service... $service"
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
                
                $Status = "FAILED"
                $AccessAt = Get-Date
                Write-Error "$URI : The Site may be down, please check!"

                $LogMessage = "$service FAILED $AccessAt"                
                Write-Verbose $LogMessage
                Write-Log -Message $LogMessage -LogPath $LogPath
                
            }

            # Finally, we clean up the http request by closing it.
            If ($HTTP_Response -eq $null) { } 
            Else { $HTTP_Response.Close() }
        }
}


#Write log to the log file
function Write-Log
{
    param(
    [string] $Message,
    [string] $LogPath
    )

    Write-Verbose $Message
    Write-Verbose $LogPath
    #Make log file ready
    check-LogFile -LogPath $LogPath
    #write log
    Add-Content -path "$LogPath\log.txt" -value $Message
    Write-Verbose "Log updated"

}

#check if Log file exists else create
function check-LogFile
{
    param([string] $LogPath)
    Write-Verbose $LogPath
    #create log file if not exists
   if (!(Test-Path $LogPath))
      {
        $CurrentDatetime = Get-Date
        $LogMessage = "Log file created on $CurrentDatetime"  
        New-Item -path $LogPath -name log.txt -type "file" -value $LogMessage
        Write-Verbose "Log file created"
     }
     else
     {
        Write-Verbose "File Exists"
     }
      Write-Verbose "Log file ready"
}


#NOT WORKING
function Send-Mail
{

    Send-MailMessage -From 'techiesclub2021@gmail.com' -To 'techiesclub2021' -Subject 'Test mail' -SmtpServer smtp.gmail.com -Credential (Get-Credential) -Port 587
}

Export-ModuleMember -Function 'Check-ServiceHealth'

#Load functions
#. .\CheckServiceHealth.ps1

#call method
#Check-ServiceHealth -Services https://rbr-dev.nonprod.aws.casualty.cccis.com/isl-api1/swagger/index.html,https://rbr-dev.nonprod.aws.casualty.cccis.com/provider-api/swagger/index.html,https://rbr-dev.nonprod.aws.casualty.cccis.com/dc-api/swagger/index.html -LogPath c:\temp -Verbose