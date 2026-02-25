# Cross-Chain Bridge Logic

This repository provides an expert-level foundation for building a cross-chain token bridge. It focuses on the smart contract security layer required to lock assets on a source chain and release them on a destination chain based on off-chain validator consensus.

## Overview
The bridge utilizes a secure message-passing architecture. When a user locks tokens on Chain A, a validator (or set of validators) signs a message that allows the user to claim an equivalent amount of tokens on Chain B.

### Key Features
* **Secure Locking:** Users deposit ERC-20 tokens into the bridge contract, emitting a `Deposit` event.
* **Signature Verification:** Uses ECDSA to verify that release requests are authorized by the bridge's trusted validator.
* **Replay Protection:** Implements a mapping of processed hashes to prevent users from claiming the same bridge transfer multiple times.
* **Emergency Stop:** Integrated Pausable functionality to protect funds in case of external network issues.

## Technical Stack
* **Language:** Solidity ^0.8.20
* **Cryptography:** OpenZeppelin ECDSA
* **Standards:** ERC-20
* **License:** MIT

## Workflow
1. User calls `lockTokens` on the source chain.
2. Off-chain oracle/validator detects the event and signs the transaction data.
3. User (or relayer) calls `releaseTokens` on the destination chain with the validator's signature.
