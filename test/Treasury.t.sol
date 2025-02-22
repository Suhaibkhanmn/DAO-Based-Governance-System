// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Treasury.sol";

contract TreasuryTest is Test {
    Treasury public treasury;
    address public owner = address(0x1);
    address public recipient = address(0x2);

    function setUp() public {
        vm.prank(owner);
        treasury = new Treasury(owner);
    }

    function testWithdraw() public {
        vm.deal(address(treasury), 10 ether);

        vm.prank(owner);
        treasury.withdraw(payable(recipient), 1 ether);

        assertEq(address(recipient).balance, 1 ether);
    }
}
