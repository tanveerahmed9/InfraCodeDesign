Import-Module .\functionModule.psm1
Describe 'function test 2 demo'{
    It -Name 'Checks 5'{
     Mock -CommandName f2 -MockWith {"admin"}
        f1 | should be 4
        Assert-VerifiableMock -Verbose
    }

}
