#region VM deployment options

#basic cloning

$sVm = get-VM -Name "<VMname>"
$vmhost = get-cluster "HostCluster" | get-host "host" | get-random

#from template

$template = get-template -name "RHEL6-Template"
$vmCreate = New-VM -Template $template -VMHost $vmhost -Name "TVm"

# select datastore with free space is atleat 50% of total

$datastore = get-datastore | Where-Object{$_.freeSpaceGB -gt ($_.CapacityGB)*0.5} | Select-Object top 1

#registering and existing VM

New-Vm -Name "LTCTestonly" -VMHost $vmhost -VMFilePath "path of the vmx file"




#endRegion