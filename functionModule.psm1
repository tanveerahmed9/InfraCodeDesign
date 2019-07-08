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

return $testData
}
function f2()
{

}

function f3()
{
  $k =   f2 # added for mock test
 return "4"
}


Export-ModuleMember -Function f1,f2,f3