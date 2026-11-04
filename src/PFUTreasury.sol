// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title PFUTreasury
/// @notice Planned 6% system fee collector. Scope, assets, routing shares are TBD.
contract PFUTreasury is Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant FEE_BPS = 600; // 6%
    address public feeRecipient; // TBD
    address public poolRecipient; // TBD

    event FeeCollected(address indexed asset, uint256 amount, uint256 fee);

    constructor(address feeRecipient_, address poolRecipient_) Ownable(msg.sender) {
        feeRecipient = feeRecipient_;
        poolRecipient = poolRecipient_;
    }

    function collect(address asset, uint256 amount) external {
        uint256 fee = (amount * FEE_BPS) / 10_000;
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        if (feeRecipient != address(0)) IERC20(asset).safeTransfer(feeRecipient, fee);
        uint256 rest = amount - fee;
        if (poolRecipient != address(0)) IERC20(asset).safeTransfer(poolRecipient, rest);
        emit FeeCollected(asset, amount, fee);
    }
}
