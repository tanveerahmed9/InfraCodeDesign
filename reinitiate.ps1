param(
    [string] $VmName,
    [string] $VmType,
    [string] $vmDomain,
    [string] $dataCenterLocation
)

function Reinitiate-VmImpl ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # define the main code here
    $str = "Re-initiate invoked from SP"
    $vmDomain
    $str | Out-File .\Decom.txt -Append
}
function Reinitiate-VM ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # invoke the re-initiate implementation here
    decom-Vmimpl @PSBoundParameters
}

Reinitiate-VM -VmName $VmName -VmType $VmType -vmDomain $vmDomain -dataCenterLocation $dataCenterLocation


