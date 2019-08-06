## this code will not be added to git remote .. we will check the status ..


## this section is reserved for meta programming


# function  myfunc{
#     [CmdletBinding()]
#     param (
#         [Parameter(Position = 0)]
#         [object] $P1,

#         [Parameter(Position = 1)]
#         [object] $P2,

#         [Parameter(Position = 2)]
#         [object] $P3,

#         [Parameter(ValueFromPipeline = $true)]
#         [object] $ActualValue
#     )
#     Begin {
#         Write-Host "printing $p1"
#     }

#     process{
#          Write-Host "Nothing in Process block"
#     }

#     end {
#           Write-Host "end block invoked"
#     }

# }

# function  myfunc2{
#     [CmdletBinding()]
#     param (
#         [Parameter(Position = 0)]
#         [object] $P1,

#         [Parameter(Position = 1)]
#         [object] $P2,

#         [Parameter(Position = 2)]
#         [object] $P3,

#         [Parameter(ValueFromPipeline = $true)]
#         [object] $ActualValue
#     )
#     Begin {
#         Write-Host "printing $p1"
#     }

#     process{
#          Write-Host "Nothing in Process block"
#     }

#     end {
#           Write-Host "end block invoked"
#     }

# }

# # adding default parameter set
# $PSDefaultParameterValues = @{
#     'myfunc:P1' = 'Default Pipeline'

# }


# function dcc{
#     "overriding get-date with new implementation"
# }



# $ci = Get-command -CommandType cmdlet Get-Date

# $ci.GetType()

# $a = Get-ChildItem 'C:\Users\t.b.ahmed\Documents\WindowsPowerShell' | gm Ps*

# $a = Add-Member -MemberType NoteProperty -Name Test123 -Value "test123" -PassThru
# $a | gm


#Region demonstrating noteproperty below
# $sbRev = {
#     $str = $this
#     $str = [char[]] $this
#     [array]::Reverse($str)
#     -join $str
# }

# $a = "This is a String , i will reverse this"

# Add-Member -MemberType ScriptMethod -Name Reverse -Value $sbRev  -InputObject $a -PassThru

# $a.Reverse()

#endRegion

#Region Demonstrating clousure

$c = 5
$dm = New-Module  -ScriptBlock {
    $c = 0
    function get-nextCount()
    {
        "Next count invoked"
    }
    Export-ModuleMember -Variable c
}

function New-Counter
{
param
(
[int]$increment = 1
)
$count=0;
$count += 1
{

}.GetNewClosure()

}

$nc = New-Counter

$nc.GetType()

#endRegion


#Region Demonstrating steppable pipeline
$stepPipe = { Select-Object name, length }

#endRegion

#region misc
$sp = $stepPipe.GetSteppablePipeline()
$sp.Begin($true)

$dlls = Get-ChildItem -Path $pshome -Filter *.dll
foreach ($dll in $dlls)
{
  $sp.Process($dll)
}
$sp.End()
$sp.Dispose()
$wrappedCmdlet = $ExecutionContext.InvokeCommand.GetCmdlet('out-host')
function myfunc()
{
    [CmdletBinding()]
    param()
    [Parameter(ValueFromPipeline=$true)] `
    [System.Management.Automation.PSObject] $InputObject

    $PSCmdlet

}

$k = & myfunc

ave-Module -Name Timezone -Repository PSGallery -Path "C:\Users\t.b.ahmed\Desktop\Automation\external rep\OnlineTest"

#endregion


#region scripmethod
# $sbRev = {
#     $str = $this
#     $str = [char[]] $this
#     [array]::Reverse($str)
#     -join $str
# }

# $a = "This is a String , i will reverse this"

# Add-Member -MemberType ScriptMethod -Name Reverse -Value $sbRev  -InputObject a -PassThru
# $a | gm
# $a.Reverse()
#endregion

#region closure
function test-mytest([string] $myStr) {return {param([int] $x) "$myStr ... $x"
$myStr = "New Developer"}.GetNewClosure()}

$testObj1 = test-mytest "Author- Tanveer Ahmed"
$testObj2 = test-mytest "Author - Developer 1"
$testObj3 = test-mytest "Author - Developer 2"
$testObj3 = test-mytest "Author - Developer 3"
& $testObj1 9
& $testObj2 8
& $testObj3 9


#region related notes
<#
each instance will has its own copy in the runspace .
each instance retains the value of the function scope if we use Closure
When a module
is loaded, the exported members are closures bound to the module object that was
created
#>

#end region



#endregion

#endregion


#region Module as custom object
function modfunctest
{
  New-Module -ArgumentList $args -AsCustomObject{
    param(
      [int] $initial = 0,
      [int] $final = 0
    )
    function converttostring()
    {
      "$initial.. $final"
    }
    Export-ModuleMember -Function converttostring -Variable initial,final
  }

}

$ins1 = modfunctest 1 9
$ins2 = modfunctest 2 10
$ins3 = modfunctest 3 11


$ins1.converttostring()

#region Notes
<#
The difference between normal custom object and Module custom object is the ability
to make stromgly typed members. (see above example [int]$inital and [int]$ final)
#>

#endregion

#endRegion

#region Steppable pipeline (unique to PS not in python)
$SB1 = {Select-Object Name}
$SB2 = {Where Name like "*SQL*"}

$SP1 = $SB1.GetSteppablePipeline()
$SP2 = $SB2.GetSteppablePipeline()

$sp1.Begin($true)

$services = get-service -Name "*SQL*"

foreach ($service in $services) {
  $sp1.Process($service)
}

$SP1.End()
$SP1.Dispose()




#region Notes for steppable pipeline
<#
Majorly useful in wrapping functions (see example out-default)

In the example of out-default since functions are loaded before cmdlets our function will be invoked first
chapter 7 on why we added $PSCmdlet instead of a boolean

#>

#endRegion

#endregion

#region property wrapping (similar to overriding in C#)

$item = get-item C:\abc
$item.PSObject




#endRegion