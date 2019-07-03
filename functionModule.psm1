# this is just for pester POC


function f1()
{
$testData = "test1,test2,test3"
$testData = $testData -split ","
if ($false)
{
    $l = f2
}
$testData += $l
$count = $testData.count
return "$count"
}
function f2()
{

}


Export-ModuleMember -Function f1,f2