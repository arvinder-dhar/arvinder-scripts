<#
.Synopsis
   This Function will display uptime of computer(s)
.DESCRIPTION
   This Function will display last Boot up date of computer and
   Will calculate the uptime in days based on that Boot up date
.EXAMPLE
   Getting information for the local computer
   Get-Uptime -ComputerName localhost
.EXAMPLE
   Getting information for remote computers
   Get-Uptime -ComputerName comp1, comp2
 .EXAMPLE
   Getting information for remote computers fetched from a text file
   Get-Content c:\servers.txt | Get-Uptime
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Function written by Arvinder
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

Function Get-Uptime {
    [CmdletBinding()]
    Param(
        #Want to support multiple computers
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName
    )
    
 Begin{}
 Process{

 foreach($Computer in $ComputerName){

    $remote= [bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue)
    $ping = Test-Connection -ComputerName $Computer -Quiet -Count 2

 if ($remote -eq "True" -and $ping -eq "True") {

    $Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer -ErrorAction SilentlyContinue
    $startdate = $Boot.ConvertToDateTime($Boot.LastBootUpTime)

    $EndDate =  Get-Date
    #$uptime = (New-TimeSpan -Start $startdate -End $EndDate).days

    $uptime = (New-TimeSpan -Start $startdate -End $EndDate).days + [math]::round((New-TimeSpan -Start $startdate -End $EndDate).hours/24,2)

    if ($computer -like "localhost"){

    $Prop=[ordered]@{ #With or without [ordered]
                'Computer Name'=$env:COMPUTERNAME;
                'Last Reboot Date '=$startdate;
                'Uptime (Days)'=$uptime;
                }
                }
          
            else  {
                $Prop=[ordered]@{ #With or without [ordered]
                'Computer Name'=$Computer;
                'Last Reboot Date '=$startdate;
                'Uptime (Days)'=$uptime;
                }
            }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

else {
            
        $Prop=[ordered]@{ #With or without [ordered]

                'Computer Name'=$computer;
                'Last Reboot Date '="Computer Not Reachable";
                'Uptime (Days)'="NA";
                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

        }
   }

 End{}
}
