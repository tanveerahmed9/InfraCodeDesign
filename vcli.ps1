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

#region Search through datastore to find a file which matches a pattern


#endregion


#region using VCLI API's for building CI's
<# Requirement and solutioning

2 vCPUs
4 GB of RAM
40 GB thin-provisioned system drive
second paravirtual SCSI controller with a 5 GB and a 10 GB hard disk
2 VMXNET adapters on VLANs 22 and 100
connection from the CD drive to the Windows ISO to facilitate the OS installation

We also want to enable hot add CPU and memory and set a resource allocation
reserving 60 percent of the configured RAM as well as set a high CPU share. We
need this VM created in the SQL folder and assigned to the SQL resource pool.

Classes to be used:-

VMware.Vim.VirtualMachineConfigSpec - for basic config (ram,cpu etc)
VMware.Vim.VirtualDeviceConfigSpec  - Hardware device config (scsi,cdrom,disk etc)

   VMware.Vim.VirtualCdrom - Virtual CD rom
   VMware.Vim.VirtualLsiLogicSASController - for SCSI
   vmware.Vim.VirtualDisk - For Disk

   Onyx tool can be helpful in generating the code
#>




#endregion