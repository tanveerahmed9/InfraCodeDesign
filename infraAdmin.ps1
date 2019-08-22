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

#region adding type (similiar to add-type cmdlet)
$item = get-item C:\abc
[int] $myVar = 10
$Customnoteproperty = New-Object System.Management.Automation.PSVariableProperty -ArgumentList (Get-Variable myVar)
$customVariableproperty = [psvariableproperty]::new('get-variable myVar')
$item.PSObject.Members.Add($Customnoteproperty)
$item.PSObject.Members.Add($customVariableproperty)

$item.PSObject.Members | Where-Object {$_.name -like '*Note*'}
$item.myvar
#endRegion

#region Adding new members to a type instead of instance (scriptmethod to an object)
$sumScBlock = {
  $r = 0
  foreach($s in $this){$r += $s}
  $r
}
Update-TypeData -TypeName "System.Array" -MemberType ScriptMethod -MemberName "Sum" -Value $sumScBlock
update-typeData .\Customtype.ps1xml

<#notes
We can either create a scripmethod and add to the basic Data type or we can create and XML
and import the XML in the session for using the extended member in the Data type

When defining dynamic types b you need to supply Update-TypeData with several
pieces of information:
■■ Type to be modified
■■ Name of the new member
■■ Type of the new member
■■ Value or code used to define the new member

#>

#endregion

#region demonstratio of $executionContext
$ec = $executionContext.InvokeCommand  | gm # expandstring(), invokescript() , newscriptblock()

#expandstring()
$a = 55
$statement = 'a is $a'
"$statement"
$executionContext.InvokeCommand.ExpandString($statement) # expandstring helps in resolving var in runtime


#invokescript()
#same as Invoke-Expression

#attaching scripblock to  the session

$sb = {1..10 | foreach{($_*2)}}
$executionContext.InvokeCommand.NewScriptBlock($sb)
& $sb

#using type accelarator

$SB11 = [scriptblock]::Create($sb)
& $SB11

#endregion

#region function Drive
$x = 5
$y = 9
$Function:myfunc = "$x*$y"
myfunc

$Function:expandedFunc = "$Function:myfunc*296" # further expansion of the function using
#function drive
expandedfunc


#endregion

#region Add type (C# code coerage)
Add-Type @'
using System;
public static class Example1
{
public static string Reverse(string s)
{
Char[] sc = s.ToCharArray();
Array.Reverse(sc);
return new string(sc);
}
}
'@

$string = "Reverse This"
$csObj = [Example1]::Reverse($string)


#endregion

#region cmdletBinding examples (under the hood)

function myFunction {[CmdletBinding()]param() "Explicitly creates advanced functions"}
Get-Command myFunction -Syntax


function stop-processCustom{
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [parameter(Mandatory=$true)]
    [string]$pattern
  )
  $process = gwmi win32_process | where name -like "*$pattern*"

  if ($pscmdlet.ShouldProcess("Process $($process.Name) with ID : $($process.processID) will be stopped"))
  {
    $process.terminate()
  }

}

stop-processCustom -pattern "Notepad" -WhatIf

stop-processCustom -pattern "Notepad"
#supports paging demo


<#
Following values attributes can be specified in cmdlet bindings

1. ConfirmImpact
when the value of confirmImpact is higher than the confirm preference variable
shouldprocess

2. DefaultParameterSetName

3. HelpUri

Link to Online help

4. Supportspaging

adds the First, Skip, and IncludeTotalCount

$pscmdlet.pagingparameters.Skip
$pscmdlet.pagingparameters.First
$pscmdlet.pagingparameters.includetotalcount
$pscmdlet.pagingparameters.newtotalcount()

5. SupportsShouldProcess

enables -confirm and -whatif parameters
see example stop-process for demo

#>



#my change1

#my change22
#endregion


#region testing output type attribute
function set-outputcheck{
[CmdletBinding(DefaultParameterSetName='int')]
[OutputType('asInt', [int])]
[OutputType('asString', [String])]
[OutputType('asDouble', ([double], [single]))]
[OutputType('lie', [int])]

param(
  [parameter(ParameterSetName='asInt')] [Switch] $asInt,
  [parameter(ParameterSetName='asString')] [Switch] $asString,
  [parameter(ParameterSetName='asDouble')] [Switch] $asDouble,
  [parameter(ParameterSetName='lie')] [Switch] $aslie
)

Write-Host "Parameter set: $($PSCmdlet.ParameterSetName)"
switch ($PSCmdlet.ParameterSetName) {
'asInt' { 1 ; break }
'asString' { '1' ; break }
'asDouble' { 1.0 ; break }
'lie' { 'Hello there'; break } }
}

(set-outputcheck -asDouble ).GetType()

(Get-Command set-outputcheck).OutputType

<#
Parameter set name is related to Output type (see set-outputcheck example)

#>

#endregion

#region Parameter set name
function Test-ParameterSets
{
param (
[parameter(ParameterSetName='s1')] $p1='p1 unset',
[parameter(ParameterSetName='s2')] $p2='p2 unset',
[parameter(ParameterSetName='s1')]
[parameter(ParameterSetName='s2',Mandatory=$true)]
$p3='p3 unset',
$p4='p4 unset'
)
'Parameter set = ' + $PSCmdlet.ParameterSetName
"p1=$p1 p2=$p2 p3=$p3 p4=$p4"
}
Get-Command Test-ParameterSets -Syntax
Test-ParameterSets -p1 one -p4 four


<#


#>
#endregion

#region valuefrompipeline by property name
function valuefromPipelinetest {
  param (
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $dayofweek
  )

  "time of day is $dayofweek"
}

get-date  | valuefromPipelinetest

# mini topic added ValueFromRemainingArguments=

function valuefromremaningtest{
  param(
    $first,
    [parameter(ValueFromRemainingArguments=$true)]
    $others
  )
"first parameter $first"
"others $others"
}

valuefromremaningtest "myfirst" "mysecond" "mythirf" "myfourth" "myfifth"



<#
This helps in bindings paraeter from the pipeline to the parameter in the
function with same name see function valuefromPipelinetest for reference.
#>

#endregion

#region validate parameter for its values

# 1.validate count (specifies minimum and maximum no of elements in an array)
function myfunc2 {
  param (
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [ValidateCount(2,4)]
    [int[]]
    $arr
  )


}
$arr = 1,2,3,4
myfunc2 $arr

#2. Validate length

#3 Validate Pattern

function validatepatterntest {
  param (
    [Parameter()]
    [string]
    [ValidatePattern('^[a-z][0-9]{1,7}$')]
    $hostname
  )

 "Hostname : $hostname"
}

validatepatterntest -hostname "h12321"

#4 . validate range

#5.  validate sets

#6. Validate script
function scriptparams {
  param (
    [Parameter(ValueFromPipeline=$true)]
    [int]
    [ValidateScript({$_ * 2 -eq 4})]
    $dnName
  )

}


scriptparams 2
#endregion

#region Default values
function DefaultTite{
  [CmdletBinding()]
  param(
   $legacy1,
   $legacy2,
   $legacy3
  )
  "Legacy 1 is $legacy1"
  "legacy 2 is $legacy2"
  "legacy 3 is $legacy3"
}

$PSDefaultParameterValues = @{
  'DefaultTite:legacy1' = "Legacy 1 defaulted" ;
  'DefaultTite:legacy2' = "Legacy 2 defaulted" ;
  'DefaultTite:legacy3' = "Legacy 3 defaulted"
}

DefaultTite

#endregion

#region Remoting

<#
(Get-Item .\TrustedHosts).Value

$cred = Get-Credential
Invoke-Command -ComputerName localhost -ScriptBlock { 1..3 } -Credential $cred | sort -Descending
the above command wont work in proper format as the semantic has been changed to make the above code
work we need to us the input variable

1..3| invoke-command -computer <ListOfComms> -scriptblock {
"start"
$input | sort -desc
"end"
}

1..3 | foreach { Write-Host $_ -ForegroundColor green;
$_; Start-Sleep 5 } | Write-Host

#>

# Build a multi-Machine monitoring

function multi-machineMonitoring{
  [CmdletBinding()]
  param(

    [string]$serverList = "server.txt",
    [int] $throttleLimit = 10,
    [int] $numProcess = 5)

    #creating a common scriptblock for gathering remote VM Info for monitoring
    $gatherInformation = {
        param([int] $procLimit = 5)
        {
          $Date = Get-Date
          $FreeSpace = (Get-PSDrive c).Free
          $PageFaults = (Get-WmiObject Win32_PerfRawData_PerfOS_Memory).PageFaultsPersec
          $TopCPU = Get-Process | Sort-Object CPU -Descending |  Select-Object -First $procLimit
          $TopWS = Get-Process | Sort-Object WS -Descending | Select-Object -First $procLimit
        }
    }

    $servers = Import-Csv $serverList | Where-Object ($_.Day -eq (get-date).DayOfWeek) | ForEach-Object ($_Name)
    Invoke-Command -ComputerName "<RCom>" -ScriptBlock $gatherInformation -ThrottleLimit $throttleLimit
}

# check the above code running on a networked VM

#compare the time taken in PSSession and Invoke-command

#The two most expensive penalties with remoting are setting
#up the session and serializing the return data

# implicit remoting : This would be useful when you want to run those cmdlets which are not
# available locally

$session = New-PSSession -ComputerName "<TServer>"

Invoke-Command -Session $session -ScriptBlock {get-exchangeserver -CI localhost}
Import-PSSession -Session $session -CommandName get-exchangeserver
get-exchangeserver ## this is like fetching a cmdlet from a module
Remove-PSSession # PSSession removed

$g = get-command -Name multi-machineMonitoring

#endRegion
