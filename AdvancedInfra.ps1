
function use-pipe {
    [CmdletBinding()]
    param (
       [parameter(ValueFromPipeline)]
       [string] 
       $pObj
    )
    
    begin {
       $lObj =  New-Object "System.Collections.Generic.List[Int]"
       Write-Verbose "begin block"
    }
    
    process {
        $lObj.Add($pobj)
    }
    
    end {
        Write-Verbose "end block"
        return $lObj
    }
}
    
## git branching test 
$proc = Get-CimInstance -ClassName CIM_Processor
$runspacepool = [runspacefactory]::CreateRunspacePool(1,$proc.NumberOfLogicalProcessors, $Host)
$runspacepool.Open()
# We need to collect the handles to query them later on
$Handles = New-Object -TypeName System.Collections.ArrayList
# Queue 1000 jobs
1..1000 | Foreach-Object {$posh = [powershell]::Create()
$posh.RunspacePool = $runspacepool
# Add your script and parameters. Note that your script block may of
#making changes in the master branch and then will commit

$null = $posh.AddScript( {
param
(
[int]$Seconds
)
Start-Sleep @PSBoundParameters})
$null = $posh.AddArgument(1)
[void] ($Handles.Add($posh.BeginInvoke()))
}
$start = Get-Date
while (($handles | Where-Object IsCompleted -eq $false).Count)
{
Start-Sleep -Milliseconds 100
}
$end = Get-Date
Write-Host ('It took {0}s to sleep 1000*1s in up to {1} parallel runspaces'-f ($end -$start).TotalSeconds, $proc.NumberOfLogicalProcessors)

# When done: Clean up
$runspacepool.Close()
$runspacepool.Dispose()

$body = @{
    title = 'Tanveers post'
    body = 'This is test post from PowerShell'
    userID = '123'

}
$jsonBody = $body | ConvertTo-Json

 Invoke-RestMethod -Method GET -Uri https://jsonplaceholder.typicode.com/posts # -Body $jsonBody -ContentType "Application/json"
## hotfix implemented for story 423SN
# hotfix 423aSN

$polarisPath = [System.IO.Path]::GetTempFileName() -replace'\.tmp','\Polaris'
git clone "https://github.com/powershell/polaris" $polarisPath
Import-Module $polarisPath
$request

