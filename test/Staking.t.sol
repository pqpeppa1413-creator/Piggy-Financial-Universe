// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/PFUStaking.sol";
import "../src/PFUPointsLedger.sol";
import "../src/mocks/MockERC20.sol";

contract StakingTest is Test {
    PFUStaking staking;
    MockERC20 peppa;

    function setUp() public {
        peppa = new MockERC20("PEPPA", "PEPPA", 18);
        address[] memory assets = new address[](1);
        assets[0] = address(peppa);
        staking = new PFUStaking(assets, address(0), 10_000, 10_000, 20_000, 40_000);
        peppa.approve(address(staking), type(uint256).max);
    }

    function test_FlexibleStakeAndUnstake() public {
        uint256 id = staking.stake(address(peppa), 100 ether, 0);
        assertEq(staking.ownerOf(id), address(this));
        staking.unstake(id, 100 ether);
        assertEq(staking.positions(id).principal, 0);
    }

    function test_LockedRequiresUnlock() public {
        uint256 id = staking.stake(address(peppa), 100 ether, 21 days);
        vm.expectRevert("locked");
        staking.unstake(id, 100 ether);
        vm.warp(block.timestamp + 22 days);
        staking.unstake(id, 100 ether);
    }
}
