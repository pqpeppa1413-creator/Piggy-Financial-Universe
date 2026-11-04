// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPointsLedger {
    struct Lot {
        uint128 amount;
        uint64 issuedAt;
        uint64 expiresAt;
    }

    function balanceOf(address account) external view returns (uint256);
    function lotsOf(address account) external view returns (Lot[] memory);
    function mint(address account, uint256 amount, uint64 validitySeconds) external;
    function spend(address account, uint256 amount) external returns (uint256 spentFromLot);
    function refund(address account, uint256 amount) external;
}
