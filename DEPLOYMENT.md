# Deployment Guide

## Prerequisites

- [Foundry](https://book.getfoundry.sh/) installed
- RPC URL for Portaldot
- Deployer private key with gas
- Addresses for: allowlist assets, boost provider, fee recipient, pool recipient

## 1. Install dependencies

```bash
forge install
```

This repository expects:

- `lib/openzeppelin-contracts`
- `lib/forge-std`

If they are missing:

```bash
forge install foundry-rs/forge-std --no-commit
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

## 2. Configure environment

Create `.env`:

```bash
PORTALDOT_RPC=https://rpc.portaldot.example
PRIVATE_KEY=0x...
PEPPA_ADDRESS=0x...
POT_ADDRESS=0x...
USDT_ADDRESS=0x...
BOOST_PROVIDER_ADDRESS=0x...
FEE_RECIPIENT=0x...
POOL_RECIPIENT=0x...
DAILY_POOL=0
```

Never commit `.env`.

## 3. Configure parameters

Edit `script/Deploy.s.sol` before running:

- term weight multipliers
- daily points pool
- minimum stake amounts (to be added)
- fee routing recipients
- boost provider

## 4. Build and test

```bash
forge build
forge test
```

## 5. Dry run

```bash
forge script script/Deploy.s.sol --rpc-url $PORTALDOT_RPC
```

## 6. Broadcast

```bash
forge script script/Deploy.s.sol --rpc-url $PORTALDOT_RPC --broadcast
```

## 7. Post-deployment checklist

- [ ] Record all deployed addresses in `docs/ADDRESSES.md`
- [ ] Transfer ownership of `PFUPointsLedger` to the distributor
- [ ] Verify source code on the explorer
- [ ] Set allowlist assets
- [ ] Set initial daily pool
- [ ] Confirm no leftover admin powers that can move user funds
- [ ] Run a test stake, settlement, unstake, and spend on testnet
- [ ] Publish an audit report before mainnet
