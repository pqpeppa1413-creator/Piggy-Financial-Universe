# Architecture

PFU separates custody, accounting, distribution, and treasury into distinct modules.

```
assets (PEPPA / POT / USDT)
        │
        ▼
┌──────────────┐   weight    ┌────────────────────┐
│ PFUStaking   │ ──────────► │ PFUPointsDistributor│
│ custody      │             │ daily pool settlement│
└──────────────┘             └────────────────────┘
        │                                  │ mint
        │                                  ▼
        │                        ┌────────────────────┐
        │                        │ PFUPointsLedger     │
        │                        │ non-transferable    │
        │                        │ 180-day lot expiry   │
        │                        └────────────────────┘
        │                                  │ spend / refund
        ▼                                  ▼
   user principal                   Marketplace / products
                                           │ fee
                                           ▼
                                   ┌──────────────┐
                                   │ PFUTreasury  │
                                   │ planned 6%   │
                                   └──────────────┘
```

## Module responsibilities

| Module | Responsibility | Out of scope |
| --- | --- | --- |
| PFUStaking | Holds principal, tracks terms, computes effective weight | Pricing, yield promises |
| PFUPointsDistributor | Settles daily pool to positions by weight | Minting supply arbitrarily |
| PFUPointsLedger | Tracks points lots, expiry, spends, refunds | Transfer between users |
| PFUTreasury | Collects planned fee and routes to recipients | Market making, investment |

## Effective weight

```
weight = principal × termMultiplier × boostBps / 10_000
```

Term multipliers and NFT boost basis points are TBD economic parameters.

## Points formula

```
points_i = pool_day × weight_i / total_weight
```

The whitepaper states this is a mechanism model, not a confirmed on-chain formula. Snapshot timing, rounding, and batch distribution are implementation choices to validate.
