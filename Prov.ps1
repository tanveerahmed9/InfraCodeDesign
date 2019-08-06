param(
    [string] $VmName,
    [string] $VmType,
    [string] $vmDomain,
    [string] $dataCenterLocation
)

function prov-VMimpl ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # define the main code here
    $str = "Provisioning  invoked from SP"
    $str
    $str | Out-File .\Prov.txt -Append
}
function prov-VM ($VmName,$VmType, $vmDomain, $dataCenterLocation) {
    # invoke the re-initiate implementation here
    prov-VMimpl @PSBoundParameters
}

prov-VM -VmName $VmName -VmType $VmType -vmDomain $vmDomain -dataCenterLocation $dataCenterLocation

