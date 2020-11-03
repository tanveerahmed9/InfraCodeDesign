<#
Comparison operator in PowerShell
Comparing for :
      Equality/Equivalence
      Ordinality/ Relational Inequality
Creating Comparable Classes with PowerShell
      IComparable
      IComparer, IEqualityComparer
#>

<#
Overloaded Operators
-contains
-eq
-lt
-gt
-in
-ne
-le
-ge

Others
-is
-like
-match
#>

# ordinal comparison works in case of overloaded opeartors , the right side of the equation is converted to the type of
# left side
1 -eq '1'
1 -lt '2'
'2' -eq 2


# it is important to keep the type which need not be converted be kept at left hand side
# lets take example of Null

$Object = ""

#not very accepted way
$Object -eq $null
$null -eq $Object

if ($Object -isnot [ExpectedType]){
# skip
}


#scalar comparison
'IISResetme' -match 'IIS'
@('IISResetme' , 'IISdonotRest', 'IIDDSresetForce') -match 'IIS'


# when matched against a list the match operator lists out only those member which matches the string on the right hand side

[Somearray]::sort # the sort static method uses introsort hybrid technique to sort the data (Quick, Heap, Insertion)

$someArray = @('ab', 'fg', 'cd', 'de') | Sort-Object
$someArray

# lets do a Multi-Level Sorting
1..9 | Sort-Object {$_ % 3}

1..9 | Group-Object {$_ % 3}

1..9 | Group-Object {$_ % 3} -AsHashTable

Get-Service | Group-Object StartType

Get-Service | Group-Object StartType  -NoElement


# sorting hastables

$hashExample = @{
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
}

$hashexample = $hashExample.GetEnumerator() | Sort-Object Key

# the above example coverts the hastable to an array in order to sort it out.
# to maintain the hashtable type consistency we need to copy the array to the copy hashtable over the pipeline

$hashExample = @{
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
}
$copy = @{}
$hashexample = $hashExample.GetEnumerator() | Sort-Object Key | ForEach-Object {$copy[$_.Key] = $_.Value}
$copy.GetType() # this returns the hastbale type

# the above example will the o/p to be in scrambled format , to make it ordered , we use ordered dictionary

$hashExample = @{
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
}
$copy = [Ordered]@{}
$hashexample = $hashExample.GetEnumerator() | Sort-Object Key | ForEach-Object {$copy[$_.key] = $_.Value}

 #region Icomparable members;
<#
Intefrace Icomparable members

public int CompareTo (Object obj); C#
 [int] CompareTo (Object obj); C#

# returns

Value                       Meaning
-------                    ----------
Less than Zero             This instance preceedes Obj in the sort order
Zero                       This instance occurs in the same position in the sort order
Greater than Zero          This instance follows Obj in the sort order

#>

# without using the IComparable Interface

Class DerivedComaparator{
    [int]$value
}

# if we create 10 object of random number and try to sort it wont sort the object

$instances = 1..100 | get-random -count 10 |% {[DerivedComaparator]@{value=$_}}

$instances | sort-object # this does not sort .. why?

# now lets Implement this using the Icomparable interface

Class Interfacetesting : IComparable{
    [int] $value
    [int]CompareTo([object]$other)
    {
       return $this.value.CompareTo($other.value)
    }
}

$instance = 1..100 | get-random -count 10 | %{[Interfacetesting]@{value=$_}}

# real world example



 #endregion








