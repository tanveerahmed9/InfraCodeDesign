param(
    [string] $VmName,
    [string] $VmType,
    [string] $vmDomain,
    [string] $dataCenterLocation
)

function decom-VmImpl ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # define the main code here
    $str = "Decomission invoked from SP"
    $vmDomain
    $str | Out-File .\Decom.txt -Append
}
function Decom-VM ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # invoke the re-initiate implementation here
    decom-Vmimpl @PSBoundParameters
}

decom-VmImpl -VmName $VmName -VmType $VmType -vmDomain $vmDomain -dataCenterLocation $dataCenterLocation

