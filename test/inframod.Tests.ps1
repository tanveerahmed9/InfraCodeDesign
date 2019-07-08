Import-Module .\functionModule.psm1


#region Arrange block


#endregion

#region action block
Describe 'function test 2 dev'{

    context "mock scoped tests here"{

    It -Name 'Vcenter check'{
     Mock -CommandName f2 -MockWith {"admin"}
        f1 | should contain "Prod"
    }
    It -Name "checks array value"{
      $dir = f1
      $dir[0] |should not be "Dev"
      #$dir[0] | should not be "test1"

    }
}

    Context "new mocked scope"{

    }
}

#endregion
