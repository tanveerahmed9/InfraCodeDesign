
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
    


