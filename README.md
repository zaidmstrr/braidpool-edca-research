
# Block-Settled EDCA
**Exponentially Decayed Cohort Average for Decentralized DAG Mining Pools**

[![Formal Verification](https://img.shields.io/badge/Verified-Lean%204-blue.svg)](#2-formal-verification)
[![Protocol Specification](https://img.shields.io/badge/Specification-Available-success.svg)](./PAPER.md)

This repo contains the new decentralization payout algorithm specifically created for Braidpool based on the Directed-Acyclic-Graph (DAG) architecture. But generally the idea can be applied to any pool that works with the DAG principles. Standard payout algorithms like PPLNS, the geometric method, and shift-PPLNS are traditional approaches that are designed for the linear share chains and rely on sequential state transitions. Braidpool runs on a decentralized Directed Acyclic Graph, which can process and add shares concurrently, ensuring that the work from two different miners will be treated as the same if it lies in the very few fraction of time difference and refers to the same DAG tip. 

## Core Protocol Guarantees

By strictly bounding the mathematics to the topological reality of a DAG, Block-Settled EDCA formally guarantees the following game-theoretic defenses:

1. **Sybil Resistance ($N$-Split Linearity):** The payout function is strictly linear. Splitting hashrate across multiple node identities yields exactly zero mathematical advantage, forcing attackers to absorb maximum network fee friction.
2. **MEV "Fee Sniper" Defense:** The opportunity cost of abandoning the pool to solo-mine a high-fee block strictly scales with the amplified Miner Extractable Value (MEV). Pool-hopping is a mathematically negative Expected Value (EV) action.
3. **Selfish Mining Nullification:** Because DAGs merge concurrent shares rather than orphaning them, withholding a share artificially increases its topological age. The continuous exponential decay algorithm ensures that artificially aged shares receive a strictly lesser valuation, penalizing the attacker.

## Repository Navigation

This repository is divided into two primary sections: Protocol Design and Formal Verification

### 1. Protocol Specification
The complete academic and architectural specification for the Block-Settled EDCA mechanism. This document covers the transition from legacy variable-difficulty (Vardiff) systems to uniform Braidpool difficulty ($D_{bp}$), the underlying economic equations, and the deterministic sub-dust UTXO redistribution logic.
* **[Read the Full Paper](./PAPER.md)**

### 2. Formal Verification
All game-theoretic and economic claims made in the protocol specification have been computationally verified using the **Lean 4** theorem prover. This directory contains the strict algebraic proofs confirming the protocol's linearity and decay bounds.
* **[Read the Economic Theory & Math Setup](/proofs/README.md)**
* **[Sybil Resistance (Base Case & $N$-Split)](/proofs/Sybil.lean)**
* **[MEV Opportunity Cost](/proofs/MevCost.lean)**
* **[Share Withholding Penalty](/proofs/Withholding.lean)**  

## Verifying the Proofs Locally

To compile and verify the mathematical proofs on your own machine, you will need the [Lean 4 toolchain](https://leanprover.github.io/lean4/doc/setup.html) installed or the web [Lean Compiler](https://live.lean-lang.org/).

## License & Copyright

Copyright (c) 2026 Mohd Zaid and Braidpool contributors.

The protocol specifications, technical documentation, and mathematical proofs in this repository are licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).  
You are free to share and adapt this material for any purpose, even commercially, provided you give appropriate credit to the original author(s) and distribute your contributions under the same license as the original.

Disclaimer: The Lean 4 proofs and mathematical models are provided "as is" and without warranty. Anyone implementing this protocol is responsible for their own real-world testing and network simulation.

> **Author's Note:** The core architecture, mathematical proofs, and implementations are original work. Large Language Models were utilized strictly for copyediting, structural formatting, and refining the technical documentation.