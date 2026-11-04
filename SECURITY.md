# Security

## Status

This codebase is a **reference implementation**. It has not been audited, formally verified, or deployed.

## Known limitations

- `totalWeight()` is a stub; a production version must maintain an accumulator on stake/unstake.
- No reentrancy on points spend beyond `onlyOwner`; marketplace integration must be reviewed.
- Multisig and timelock are not implemented.
- Parameter changes are owner-only in this draft.
- No pause or emergency exit.
- NFT boost provider is an external call and must be treated as untrusted.

## Before mainnet

1. Independent audit.
2. Replace owner with a timelocked multisig.
3. Implement pause and invariant monitoring.
4. Add batch settlement and gas accounting.
5. Verify rounding and expiry edge cases.
6. Run testnet for at least one full settlement cycle.

## Reporting

Do not open a public issue for critical vulnerabilities. Contact the PFU security maintainers privately.
