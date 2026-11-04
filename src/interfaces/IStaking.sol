// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStaking {
    struct Position {
        address asset;
        uint256 principal;
        uint64 openedAt;
        uint64 unlockAt; // 0 for flexible
        uint64 termDays;
    }

    function positions(uint256 positionId) external view returns (Position memory);
    function ownerOf(uint256 positionId) external view returns (address);
    function stake(address asset, uint256 amount, uint64 termDays) external returns (uint256 positionId);
    function unstake(uint256 positionId, uint256 amount) external;
    function weightOf(uint256 positionId) external view returns (uint256);
    function totalWeight() external view returns (uint256);
}
