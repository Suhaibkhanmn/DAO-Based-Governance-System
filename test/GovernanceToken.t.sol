// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken public token;
    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new GovernanceToken(owner);
    }

    function testMinting() public {
        vm.prank(owner);
        token.mint(user, 1000);
        assertEq(token.balanceOf(user), 1000);
    }
}
