pragma solidity ^0.4.18;
import "browser/AutoVend.sol";

contract AutoVendTest {

    function testMachine(AutoVend machine) payable returns (uint256) {
        // machine.stg[0] = _item1;
        // machine.stg[0] = _item2;
        // machine.stg[0] = _item3;
        uint256 fails;
        VendTestBuyer person1 = new VendTestBuyer(machine);
        bool tx1 = person1.doVend(0,3);
        if(tx1) {
            fails++;
        }
        // uint32 tmp = machine.getItem(0).cnt;
        // if ( tmp == 48) {
        //     result+=1;
        // }
        // if (machine.balance != 50) {
        //     result+=1;
        // }
        delete person1;
        return fails;
    }
    
    function AutoVendTest() payable {
        // create the test vending machine to be tested
        uint256 failedTests = 0;
        AutoVend vendMachine = new AutoVend(true);
        vendMachine.addItem(0, "gum", 5, 50, 0x00000);
        vendMachine.addItem(1, "raisins", 50, 1, 0x000FF);
        vendMachine.addItem(2, "friends", 50000, 2, 0x000EE);
        failedTests += testMachine(vendMachine);
    }
}

/* TEST BUYER */
contract VendTestBuyer {

    AutoVend _target;
    function VendTestBuyer(AutoVend target) payable {
        _target = target;
    }
    
    // //Payable function
    // function () public payable {
        
    // }

    function doVend(uint32 idx, uint32 qty) external payable returns (bool){
        return _target.vend.value(msg.value)(idx, qty);
    }
}