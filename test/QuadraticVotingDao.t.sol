// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/QuadraticVotingDAO.sol"; 
import "src/Treasury.sol";
import "src/GovernanceToken.sol";

contract QuadraticVotingDAOTest is Test {
    GovernanceToken public token;
    Treasury public treasury;
    QuadraticVotingDAO public dao;

    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new GovernanceToken(owner);

        vm.prank(owner);
        treasury = new Treasury(payable(owner));

        vm.prank(owner);
        dao = new QuadraticVotingDAO(owner, address(token), payable(address(treasury)));

        vm.prank(owner);
        token.mint(user, 1000);

        vm.deal(address(treasury), 10 ether);
    }

    function testCreateProposal() public {
        vm.prank(owner);
        dao.createProposal("Test Proposal", payable(address(0x3)), 100);

        (, string memory description,,,,,) = dao.proposals(1);
        assertEq(description, "Test Proposal");
    }
}
