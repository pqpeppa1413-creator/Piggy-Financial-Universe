# PFU Smart Contracts

Piggy Financial Universe (PFU) is a consumer finance ecosystem on Portaldot. This repository contains the reference on-chain implementation for staking, points, distribution, and treasury fee collection.

> **Status:** design-stage reference implementation. Unaudited. No mainnet deployment addresses are published. All economic parameters marked `TBD` must be reviewed before deployment.

## What is PFU?

Users stake PEPPA, POT, or USDT under flexible or fixed-term plans (21, 45, or 180 days), earn Piggy Points through daily settlement, and redeem points for real goods and services. Points are non-transferable and expire after 180 days by design.

## Repository layout

```
src/
  PFUStaking.sol           # custody + flexible/fixed-term staking
  PFUPointsLedger.sol      # non-transferable lot-based points with 180-day expiry
  PFUPointsDistributor.sol # daily distribution by effective weight
  PFUTreasury.sol          # planned 6% system fee collector
  interfaces/              # contract interfaces
  mocks/MockERC20.sol      # test asset
script/Deploy.s.sol        # deployment script
test/Staking.t.sol         # reference tests
docs/
  ARCHITECTURE.md          # system design
  DEPLOYMENT.md            # deploy and verification guide
  PARAMETERS.md            # tunables and TBD values
  SECURITY.md              # security model and audit status
```

## Quick start

```bash
forge install
forge build
forge test
```

## Deploy

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Parameters](docs/PARAMETERS.md)
- [Security](docs/SECURITY.md)

## License

MIT. See [LICENSE](LICENSE).
