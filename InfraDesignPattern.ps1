# using factory method for infra code
# requires version 2 and above
<#
.SYNOPSIS
This script is used for parallel reboot of a list of servers with report and auto remediation

.Description
Below code is used for  reboot of a list of servers with report and auto remediation (if required). pre and post report is generated using this 
which will have detail information of the status of the servers.

.INPUT
1. List of servers in comma separated formart
2. Change no from 3rd party applications
3. Downtime name from 3rd party applications

.OUTPUTS
1. File path of the  pre report

.NOTES
Version. 1.0
Author. Tanveer Ahmed (t.b.ahmed@accenture.com)
Creation date - 31-08-2018

.Example
"D:\Deployed_PowerShell_Scripts\RebootMM\infrareboot.ps1" "server1,server2,server3" "testchange" "testDT"

#>
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using namespace System.Management.Automation

Class RebootInfra {
    #region class members declared below
    [string] $CurrentCI 
    static [int] $value
    static [string] $ServerInfoPath
    # ordered dictionaries for pre and post comparison 
    $predisk = [System.Collections.Specialized.OrderedDictionary]::new()
    $postDisk = [System.Collections.Specialized.OrderedDictionary]::new()
    static [String] $user
    static [string]$password
    static [string] $Credential
    #endregion
    [string] $currentHost
    RebootInfra(){

    }
    RebootInfra([string] $currentHost) {
        if ($this.GetType() -eq [RebootInfra]) {
            throw "Please do not instantiate this class"
        }
        $this.currentHost = $currentHost
        Write-Host "In Base class constructr"
    }

    ClearFile() {
       
            throw "Please do not instantiate this class"
        ## remember to make this code abstract
        Write-Verbose "Clear file code to be written here in derived class"
    }

    get2k8Report() {
       
            throw "Please do not instantiate this class"
        ## remember to make this code abstract this function will work in conjunction with createreport() method .. Static members TBD  
        Write-Host "2k8 report code to be added here in derived class"
    }

    get2k12Report() {
        if ($this.GetType() -eq [RebootInfra]) {
            throw "Please do not instantiate this class"
        }
        ## remember to make this code abstract
        Write-Host "2k12 report code to be added here in derived class"
    }

    RebootCI() {
        if ($this.GetType() -eq [RebootInfra]) {
            throw "Please do not instantiate this class"
        }
        ## remember to make this code abstract
        Write-Host "Reboot code to be added here in derived class"
    }
    onlinedisk() {
        throw "Please do not instantiate this class"
        Write-Verbose "Online disk code to be added here"
    }

    ConvertCredential() {
        if ($this.GetType() -eq [RebootInfra]) {
            throw "Please do not instantiate this class"
        }
        ## remember to make this code abstract
        Write-Host "Credential to be converted here in derived class"
    }

    AppendReport() {
        if ($this.GetType() -eq [RebootInfra]) {
            throw "Please do not instantiate this class"
        }
        ## this function will use static member for value (Numbering) and report path
        Write-host "append report code to be written in derived class"
    }


}


Class SerialR : RebootInfra {
    
    SerialR([string] $currentHost): Base($currentHost) {
        Write-Host "In child class constructor"
    }

    SerialR(): Base()
    {}
    [pscredential] ConvertCredential($user, $password) { ## this method converts user name and password to credential object
        $password = $password | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential($user, $password)
        return $cred
    }

    [int] get2k12Report($currentHost, $pathFile, $value, $cred) { # this method generates reports for 2k12 servers and returns the updated index value
        $disk1 = Invoke-Command -ComputerName $currentHost -ScriptBlock {
            $disk1 = try { get-disk |Select-Object FriendlyName , operationalstatus} catch {}
            return $disk1
        }-Credential $cred

        $disk2 = Invoke-Command -ComputerName $currentHost -ScriptBlock {
            $disk2 = try { Get-Volume |Select-Object DriveLetter, HealthStatus, Size } catch {}
            return $disk2
        }-Credential $cred

        $contentString = "Below is the disk information of the server `r"
        $this.AppendReport($pathFile, $contentString)
        $value = $value + 1
        ##  $disk1 = $disk1|select FriendlyName,operationalStatus |FT -AutoSize|Out-File $serverInfoPath -Append
        $disk1 = $disk1|Select-Object-Object FriendlyName, operationalStatus
        $this.AppendReport($pathFile, $disk1)
        $this.AppendReport($pathFile, "1r")
        $this.AppendReport($pathFile, "$value .Below is the drive information for the server `r")
        $disk2 = $disk2 |Select-Object-Object-Object Driveletter, healthstatus, size
        $this.AppendReport($pathFile, $disk2)
        return $value 
    }

    AppendReport($pathFile, $content) { ## this method will append a content to an existing report 
        Add-Content -Value $content -Path $pathFile
    }

    [int] get2k8Report($value, $pathFile, $currentHost, $cred) { # this method generates reports for 2k8 servers and returns the updated index
        ## code for fecthing report for 2k8 server
        $content = "$Value .Below is the disk information for the server `r"
        $this.AppendReport($pathFile, $content)
        $value = $Value + 1

        $disk1 = Invoke-Command -ComputerName $currentHost -ScriptBlock {
            $disk1 = Get-WmiObject win32_volume |Select-Object Name, capacity, Freespace, BootVolume, FileSystem 
            return $disk1
        } -Credential $cred

        $disk1 = $disk1 |Select-Object Name, capacity, Freespace, BootVolume, FileSystem 
        $this.AppendReport($pathFile, $disk1)
        return $value 
    }

    ClearFile($postpath, $ServerInfoPath) { # this method clears unnecessary data from the report file being sent to end user 
        (Get-Content -Path $serverInfoPath).Replace('{', ' ') |Set-Content -Path $serverInfoPath
        (Get-Content -Path $serverInfoPath).Replace('@', ' ') |Set-Content -Path $serverInfoPath
        (Get-Content -Path $serverInfoPath).Replace('}', ' ') |Set-Content -Path $serverInfoPath
        (Get-Content -Path $serverInfoPath).Replace('Dummy', ' ') |Set-Content -Path $serverInfoPath
        (Get-Content -Path $postPath).Replace('{', ' ') |Set-Content -Path $postPath
        (Get-Content -Path $postPath).Replace('@', ' ') |Set-Content -Path $postPath
        (Get-Content -Path $postPath).Replace('}', ' ') |Set-Content -Path $postPath
        (Get-Content -Path $postPath).Replace('Dummy', ' ') |Set-Content -Path $postPath
        
    }

    RebootCI($currentHost, $cred) { # this method reboots the CI by using invoke-command
        # actual code for reboot
        try {
            Write-verbose "inside reboot .. rebooting $currenthost"
            $rebootC = invoke-command -ComputerName $currenthost -ScriptBlock { 
                $reboot = Restart-Computer  -Force
                return $reboot
            } -Credential $cred
        }
 
        catch {
            ## if any issue found unnecessary data will be removed from the file
            $this.ClearFile()
        }
    }

    GetOnlineDisk($currentHost, $diskstage, $cred) { #this method will return a dictionary after appending the disk details
        $OutputPosition = 0
        try {
            $finalDisk = Invoke-Command -ErrorAction SilentlyContinue -ComputerName $currentHost -ScriptBlock {
                $onlineDisk = "list disk" | diskpart | Where-Object {$_ -notmatch "offline"} 
                $filteredDisk = @()
                ### taking out all the disks from the string as the output style remains constant
                foreach ($onlineDiskS in $onlineDisk) {
                    if ($OutputPosition -ge 9) {$filteredDisk = $filteredDisk + $onlineDiskS}
                    $OutputPosition += 1           
                }

                $finalDisk = @()
                for ($j = 0; $j -lt ($filteredDisk.Count - 2) ; $j = $j + 1) {
                    $finalDisk = $finalDisk + $filteredDisk[$j].Substring(2, 6)
                }
                return $finalDisk

            }-Credential $cred

            #adding  disk content in the dictionary for pre and post check up
            $finaldiskcs = ''
            foreach ($finaldiskt in $finaldisk) {
                $finaldiskcs += $finaldiskt + ","
            }
        
            $diskstage.Add("$currentHost", "$finaldiskcs")

            ##return $diskstage retruntype to be established once we have call finalized
        }
        catch {}
    }

}

Class ParallelR : RebootInfra {
    
    ## write parallel implementation here
    ## git test
}

Class customR : RebootInfra {

}

Class InfraFactory {
    ## Factory class for creating instance
    static [RebootInfra] $CIS 
    static [object] getbytype([object] $o) {
        return [InfraFactory]::[RebootInfra].Where( {$_ -is $o})
    }

    static [object] getByName([String] $Name) { ## i the method is called by name
        return [InfraFactory]::[RebootInfra].Where( {$_.Name -eq $Name})
    }

    [RebootInfra] createInstacne([string] $type, [string] $currentHost) {
        return ( [SerialR]::new($currentHost) )
    }
   
}

# client code below
function main() {
    [InfraFactory] $infraInstance = [InfraFactory]::new()
    [RebootInfra] $rebootinfra1 = $infraInstance.createInstacne("SerialR"  ,"Localhost")
    $rebootinfra1.RebootCI("aaa", "bbb")
} 
main



