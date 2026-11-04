// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IPointsLedger.sol";

/// @title PFUPointsDistributor
/// @notice Daily points distribution by effective weight.
/// @dev Formula from whitepaper: points_i = pool_day * weight_i / total_weight.
///      The whitepaper states this is a mechanism model, not a confirmed contract formula.
///      Pool size, snapshot timing, and rounding are TBD.
contract PFUPointsDistributor is Ownable {
    IStaking public staking;
    IPointsLedger public ledger;

    uint256 public dailyPointsPool; // TBD
    uint64 public lastSettlementDay;

    event Distributed(uint64 indexed day, uint256 pool, uint256 totalWeight);

    constructor(address staking_, address ledger_) Ownable(msg.sender) {
        staking = IStaking(staking_);
        ledger = IPointsLedger(ledger_);
    }

    function setDailyPool(uint256 pool) external onlyOwner {
        dailyPointsPool = pool;
    }

    function settlementDay() public view returns (uint64) {
        return uint64(block.timestamp) / 1 days;
    }

    /// @notice Distribute to a single position. Batch gas optimization is TBD.
    function settle(uint256 positionId) external {
        uint64 today = settlementDay();
        require(today > lastSettlementDay, "already settled today");
        lastSettlementDay = today;

        uint256 weight = staking.weightOf(positionId);
        uint256 totalWeight = staking.totalWeight();
        require(totalWeight > 0, "no weight");

        uint256 points = (dailyPointsPool * weight) / totalWeight;
        address owner = staking.ownerOf(positionId);
        ledger.mint(owner, points, 0);

        emit Distributed(today, dailyPointsPool, totalWeight);
    }
}
