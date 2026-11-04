// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPointsLedger.sol";

/// @title PFUPointsLedger
/// @notice Non-transferable points with 180-day lot expiry.
/// @dev Unaudited design-stage implementation.
contract PFUPointsLedger is IPointsLedger, Ownable {
    uint64 public constant DEFAULT_VALIDITY = 180 days;

    mapping(address => Lot[]) private _lots;
    mapping(address => uint256) private _balance;

    event Minted(address indexed account, uint256 amount, uint64 expiresAt);
    event Spent(address indexed account, uint256 amount, uint256 lotId);
    event Refunded(address indexed account, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function mint(address account, uint256 amount, uint64 validitySeconds) external override onlyOwner {
        uint64 valid = validitySeconds == 0 ? DEFAULT_VALIDITY : validitySeconds;
        uint64 expiresAt = uint64(block.timestamp) + valid;
        _lots[account].push(Lot({ amount: uint128(amount), issuedAt: uint64(block.timestamp), expiresAt: expiresAt }));
        _balance[account] += amount;
        emit Minted(account, amount, expiresAt);
    }

    function spend(address account, uint256 amount) external override onlyOwner returns (uint256 spentFromLot) {
        require(amount > 0 && amount <= _balance[account], "insufficient points");
        uint256 remaining = amount;
        Lot[] storage lots = _lots[account];

        for (uint256 i; i < lots.length && remaining > 0; i++) {
            if (lots[i].expiresAt <= block.timestamp || lots[i].amount == 0) continue;
            uint256 take = remaining < lots[i].amount ? remaining : lots[i].amount;
            lots[i].amount -= uint128(take);
            remaining -= take;
            emit Spent(account, take, i);
        }

        require(remaining == 0, "expired lots too small");
        _balance[account] -= amount;
        return amount - remaining;
    }

    function refund(address account, uint256 amount) external override onlyOwner {
        _balance[account] += amount;
        _lots[account].push(Lot({ amount: uint128(amount), issuedAt: uint64(block.timestamp), expiresAt: uint64(block.timestamp) + DEFAULT_VALIDITY }));
        emit Refunded(account, amount);
    }

    function balanceOf(address account) external view override returns (uint256) {
        uint256 live;
        Lot[] storage lots = _lots[account];
        for (uint256 i; i < lots.length; i++) {
            if (lots[i].expiresAt > block.timestamp) live += lots[i].amount;
        }
        return live;
    }

    function lotsOf(address account) external view override returns (Lot[] memory) {
        return _lots[account];
    }
}
