// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INftBoost {
    /// @notice Boost multiplier in basis points (10_000 = 1x). TBD per tier.
    function boostOf(address user, uint256 positionId) external view returns (uint256);
}
