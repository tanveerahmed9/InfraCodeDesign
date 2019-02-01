$ModuleManifestName = 'inframod.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'get2k12Report'
{
    It -Name 'Fetches 2k12 Report' -Test
    {
        Mock -CommandName get2k12Report
    }
}
