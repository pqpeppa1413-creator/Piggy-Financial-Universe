// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/PFUStaking.sol";
import "../src/PFUPointsLedger.sol";
import "../src/PFUPointsDistributor.sol";
import "../src/PFUTreasury.sol";
import "../src/mocks/MockERC20.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        MockERC20 peppa = new MockERC20("PEPPA", "PEPPA", 18);
        MockERC20 pot = new MockERC20("POT", "POT", 18);
        MockERC20 usdt = new MockERC20("USDT", "USDT", 6);

        address[] memory assets = new address[](3);
        assets[0] = address(peppa);
        assets[1] = address(pot);
        assets[2] = address(usdt);

        // TBD: multipliers, boost provider, recipients, daily pool.
        PFUStaking staking = new PFUStaking(assets, address(0), 10_000, 10_000, 20_000, 40_000);
        PFUPointsLedger ledger = new PFUPointsLedger();
        PFUPointsDistributor distributor = new PFUPointsDistributor(address(staking), address(ledger));
        PFUTreasury treasury = new PFUTreasury(address(0), address(0));

        ledger.transferOwnership(address(distributor));

        console.log("PEPPA", address(peppa));
        console.log("POT", address(pot));
        console.log("USDT", address(usdt));
        console.log("Staking", address(staking));
        console.log("Ledger", address(ledger));
        console.log("Distributor", address(distributor));
        console.log("Treasury", address(treasury));

        vm.stopBroadcast();
    }
}
