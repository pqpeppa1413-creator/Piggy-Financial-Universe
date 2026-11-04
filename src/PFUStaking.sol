// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/INftBoost.sol";

/// @title PFUStaking
/// @notice Reference custody contract. Flexible + fixed-term staking.
/// @dev Unaudited design-stage implementation. All weight multipliers are TBD.
contract PFUStaking is IStaking, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint64 public constant FLEXIBLE = 0;
    uint64 public constant TERM_21 = 21 days;
    uint64 public constant TERM_45 = 45 days;
    uint64 public constant TERM_180 = 180 days;

    // TBD: economic weight multipliers, basis points (10_000 = 1x).
    uint256 public immutable FLEX_MULTIPLIER;
    uint256 public immutable TERM_21_MULTIPLIER;
    uint256 public immutable TERM_45_MULTIPLIER;
    uint256 public immutable TERM_180_MULTIPLIER;

    INftBoost public boostProvider;

    mapping(address => bool) public isAssetAllowed;
    mapping(uint256 => Position) internal _positions;
    mapping(uint256 => address) internal _ownerOf;
    uint256 public nextPositionId = 1;

    event Staked(uint256 indexed positionId, address indexed owner, address asset, uint256 amount, uint64 termDays);
    event Unstaked(uint256 indexed positionId, address indexed owner, uint256 amount);
    event AssetAllowed(address indexed asset, bool allowed);
    event BoostProviderUpdated(address indexed provider);

    constructor(
        address[] memory assets,
        address boostProvider_,
        uint256 flexMul,
        uint256 term21Mul,
        uint256 term45Mul,
        uint256 term180Mul
    ) Ownable(msg.sender) {
        for (uint256 i; i < assets.length; i++) {
            isAssetAllowed[assets[i]] = true;
        }
        boostProvider = INftBoost(boostProvider_);
        FLEX_MULTIPLIER = flexMul;
        TERM_21_MULTIPLIER = term21Mul;
        TERM_45_MULTIPLIER = term45Mul;
        TERM_180_MULTIPLIER = term180Mul;
    }

    function setAssetAllowed(address asset, bool allowed) external onlyOwner {
        isAssetAllowed[asset] = allowed;
        emit AssetAllowed(asset, allowed);
    }

    function setBoostProvider(address provider) external onlyOwner {
        boostProvider = INftBoost(provider);
        emit BoostProviderUpdated(provider);
    }

    function stake(address asset, uint256 amount, uint64 termSeconds) external override nonReentrant returns (uint256 positionId) {
        require(isAssetAllowed[asset], "asset not allowed");
        require(amount > 0, "amount zero");
        require(
            termSeconds == FLEXIBLE || termSeconds == TERM_21 || termSeconds == TERM_45 || termSeconds == TERM_180,
            "bad term"
        );

        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        positionId = nextPositionId++;
        uint64 unlockAt = termSeconds == FLEXIBLE ? 0 : uint64(block.timestamp) + termSeconds;
        _positions[positionId] = Position({
            asset: asset,
            principal: amount,
            openedAt: uint64(block.timestamp),
            unlockAt: unlockAt,
            termDays: termSeconds
        });
        _ownerOf[positionId] = msg.sender;

        emit Staked(positionId, msg.sender, asset, amount, termSeconds);
    }

    function unstake(uint256 positionId, uint256 amount) external override nonReentrant {
        Position storage p = _positions[positionId];
        require(_ownerOf[positionId] == msg.sender, "not owner");
        require(amount > 0 && amount <= p.principal, "bad amount");
        if (p.unlockAt != 0) {
            require(block.timestamp >= p.unlockAt, "locked");
        }

        p.principal -= amount;
        IERC20(p.asset).safeTransfer(msg.sender, amount);
        emit Unstaked(positionId, msg.sender, amount);
    }

    function weightOf(uint256 positionId) external view override returns (uint256) {
        Position storage p = _positions[positionId];
        if (p.principal == 0) return 0;

        uint256 mul;
        if (p.termDays == TERM_21) mul = TERM_21_MULTIPLIER;
        else if (p.termDays == TERM_45) mul = TERM_45_MULTIPLIER;
        else if (p.termDays == TERM_180) mul = TERM_180_MULTIPLIER;
        else mul = FLEX_MULTIPLIER;

        uint256 boost = 10_000;
        if (address(boostProvider) != address(0)) {
            boost = boostProvider.boostOf(_ownerOf[positionId], positionId);
        }

        return (p.principal * mul * boost) / 10_000;
    }

    function totalWeight() external pure override returns (uint256) {
        // Real implementation should maintain an accumulator on stake/unstake.
        // Left as a known TBD to avoid off-by-one in this reference draft.
        return 0;
    }

    function positions(uint256 positionId) external view override returns (Position memory) {
        return _positions[positionId];
    }

    function ownerOf(uint256 positionId) external view override returns (address) {
        return _ownerOf[positionId];
    }
}
