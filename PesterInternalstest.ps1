# custom error scoping

#region Scope deep check
    function Count-Scope {
   # skipping scope zero as error would only when a function is invoked.
   $scope = 1
   $var = "Child"
   while ($null -eq (Get-Variable -Name Error -Scope $scope -ErrorAction Ignore))
   {
    $scope++
   }
    $scope--
    return $scope
    }
   "in root Scope: $(Count-Scope)"

   & {
       "in & scriptblock Scope : $(Count-Scope)"
   }

   . {
    "in dot source scriptblock Scope : $(Count-Scope)"
    }

&{
    &{
        &{
            &{
                &{
                 "deep inside scope: $(Count-Scope) "
                }
            }
        }
    }
}

#endRegion


