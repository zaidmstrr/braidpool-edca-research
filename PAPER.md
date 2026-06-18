# Block-Settled EDCA: Mining Payouts in DAG Consensus

**Author:** Mohd Zaid @zaidmstrr   
**Copyright:** © 2026 Mohd Zaid and Braidpool contributors  
**License:** Distributed under the [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/) License.

*Author's Note: The core architecture, mathematical proofs, and implementations are original work. Large Language Models were utilized strictly for copyediting, structural formatting, and refining the technical documentation.*

## Abstract
The Bitcoin mining ecosystem faces a critical centralization crisis driven by the economic and structural limitations of existing mining pool protocols. Centralized pools force miners to surrender block template construction, enabling transaction censorship. Previous attempts at decentralized pools suffered from fatal geographic orphan penalties, chain bloat, and severe vulnerability to fee-based "pool-hopping". This proposal outlines a novel architecture for Braidpool: a peer-to-peer, censorship-resistant mining pool. By executing an **Exponentially Decayed Cohort Average** (EDCA) payout scheme combined with a dynamic Fee Amplifier over a Directed Acyclic Graph (DAG), Braidpool mathematically eliminates both time-based and fee-based pool-hopping. This creates an environment that preserves the full Expected Value (EV) of solo mining while minimizing variance to the absolute theoretical limit achievable under decentralized consensus.

## 1. Theoretical Foundation
The architecture is built upon three theoretical pillars designed to correct the game-theory failures of legacy mining pools.  

### 1.1 The DAG and Graph Cuts: Eliminating the Orphan Penalty
Traditional decentralized pools use a strict sharechain. If two miners find a share simultaneously, the network forks, and one share is orphaned , severely punishing miners operating outside of major fiber-optic hubs. Braidpool utilizes a Directed Acyclic Graph (DAG) where concurrent shares (beads) do not compete; they are merged. As long as a bead meets the global minimum difficulty floor, it is included in the state. This inclusive consensus permanently neutralizes geographic latency advantages.  
Furthermore, Braidpool identifies absolute consensus boundaries through Graph Cuts—points in the DAG where all beads on one side definitively point to all beads on the other. The beads trapped between these cuts form discrete topological layers known as Cohorts.

### 1.2 Block-Settled EDCA: Eliminating Time-Hopping
Standard PPLNS (Pay-Per-Last-N-Shares) relies on a flat window of shares. This step-function incentivizes miners to abandon the pool during "unlucky" (long) rounds to avoid having their shares pushed out of the window without compensation.  
Braidpool replaces PPLNS with the Exponentially Decayed Cohort Average (EDCA). As new cohorts are closed via Graph Cuts, the mathematical weight of older cohorts is reduced via an exponential decay factor. This "melting ice cube" effect heavily penalizes miners who abandon the pool, mathematically forcing continuous loyalty without relying on wall-clock time.  

### 1.3 The Fee Amplifier: Eliminating EV Leeching
Modern Bitcoin block rewards are highly volatile due to transaction fees. Standard decentralized pools split the reward of a found block equally among past shares , incentivizing "Fee Snipers"—miners who leech off the pool during low-fee periods, but immediately switch to solo mining when mempool fees spike.  
Braidpool introduces the Fee Amplifier. Because miners build their own block templates via a committed mempool, they must lock the template's total fee value into the bead's metadata. The protocol multiplies the bead's deterministic global difficulty by this exact fee value, ensuring the miner's pool EV dynamically and perfectly matches their solo mining EV at all times.  


## 2. Mathematical Formalization
To achieve deterministic consensus on payouts without a central server, every Braidpool node continuously traverses the DAG to calculate the Unspent Hash Power Output (UHPO) state.  

Let $D_{bp}$ represent the deterministic global difficulty required to submit a bead for the current cohort, and $B_{base}$ represent the fixed Bitcoin block subsidy. 
 Let $F_i$ equal the total transaction fees in the miner's committed block template for that specific bead.

**Equation 1: The Fee Amplifier**

In traditional centralized pools, miners have no control over block templates, and pool rewards are generalized. In Braidpool’s decentralized architecture, miners construct their own block templates. Consequently, the potential value of a submitted bead is directly coupled to the transaction fees ($F_i$) locked in that specific miner's mempool template.Let $B_{base}$ represent the fixed Bitcoin block subsidy dictated by the current epoch (e.g., $3.125$ BTC). The total expected block reward ($A_i$) for a specific bead's template is defined as:

$$A_i = B_{base} + F_i$$

This dynamic amplification ensures that miners who actively collect and include high-value transactions are proportionally rewarded for their specific contribution and current mempool state.

**Equation 2: The Raw Score**

Unlike centralized pools that rely on Variable Difficulty (Vardiff) to manage server load, Braidpool enforces a strict, uniform Global Difficulty target ($D_{bp}$) for all submitted beads. This ensures topological consistency across the DAG. A miner with larger hashrate does not submit mathematically heavier beads; they simply submit a proportionally larger volume of beads.
The base value or Expected Value (EV) of the bead ($S_i$), perfectly weighted for current market conditions, is: 

$$S_i = \frac{D_{bp}}{D_{network}} \times A_i$$
Here $S_i$ represents the pure Expected Value (EV) of a specific bead. And ${D_{bp}}$ represents the global mining pool difficulty. The ratio $\frac{D_{bp}}{D_{network}}$ calculates the strict mathematical probability that any single Braidpool bead is a valid Bitcoin block. By multiplying this probability by the fee-amplified reward ($A_i$), the score $S_i$ represents the pure, exact Expected Value of one standard unit of Braidpool work anchored to global Bitcoin consensus conditions.

**Equation 3: EDCA Weight**

Standard PPLNS systems utilize a rigid sliding window, creating a mathematical "cliff" where shares suddenly lose 100% of their value. This incentivizes pool-hopping at the window boundaries. EDCA replaces this cliff with a continuous, strictly damped decay curve tied to the DAG's topological boundaries (Graph Cuts).Let $r$ represent the fixed protocol retention multiplier (e.g., $r = 0.80$), dictating the strictness of the decay. Let $\Delta c_i$ represent the topological age of the bead, measured strictly in elapsed cohorts rather than wall-clock time. The decayed weight ($W_i$) applied to the bead's original score is calculated as: 

$$W_i = S_i \times r^{\Delta c_i}$$

As new cohorts close, the topological age ($\Delta c_i$) of historical beads increases, exponentially diluting their weight. This "melting ice cube" effect mathematically enforces continuous pool loyalty, as any absence from the pool immediately accelerates the degradation of a miner's historical claim.

​
**Equation 4: Deterministic Settlement (UHPO)**

Because Braidpool operates without a central server, the network must reach a perfectly deterministic agreement on how to distribute the $A_i$ of a newly discovered Bitcoin block. This is achieved by calculating the active Unspent Hash Power Output (UHPO) state.First, the DAG sums the decayed weights of all valid beads submitted by a specific miner $m$ to find their total score ($U_m$):

$$U_m = \sum_{i \in m} W_i$$

Next, the network normalizes this score against the active global pool weight ($U_{total}$). The final deterministic payout percentage ($P_m$) for miner $m$ is calculated as:

$$P_m = \frac{U_m}{U_{total}}$$

This final ratio represents the exact fraction of the block reward owed to the miner. Because all variables ($S_i$, $r$, $\Delta c_i$) are derived directly from the immutable DAG topology, every node calculates this identical percentage independently, allowing decentralized, trustless settlement.
 
## 3. Simulated Game Theory
To demonstrate the resilience of this architecture against adversarial pool-hoppers, we simulate a 5-cohort timeline. 

**Parameters:** Decay Retention $r = 0.80$, Base Subsidy = 3.125 BTC.  
**Miners:** Alice (Loyal), Bob (Fee Sniper), Charlie (Latecomer). Each outputs exactly 500 difficulty when active.

Note: The difficulty we are using here is constant ($500$) and not variable to make the example simple.

### 3.1 The Timeline
* **Cohort 1 (Fee Spike):** Mempool spikes to 1.25 BTC fees (Amplifier = 4.375). Alice and Bob both mine. Raw Scores: 2187.5 each.
* **Cohort 2 (Quiet):** Fees drop to 0.10 BTC (Amplifier = 3.225). Bob abandons the pool to save electricity/solo mine. Alice stays, scoring 1612.5.
* **Cohort 3 (Quiet):** Fees rise slightly to 0.15 BTC (Amplifier = 3.275). Bob remains offline. Alice stays, scoring 1637.5.
* **Cohort 4 (Waking Up):** Fees rise to 0.40 BTC (Amplifier = 3.525). Bob remains offline. Alice stays, scoring 1762.5.
* **Cohort 5 (Spike - Block Found!):** Fees jump to 1.50 BTC (Amplifier = 4.625). Bob rushes back to the pool to snipe fees. Charlie joins as a new miner. Alice stays. All three miners output 500 diff. Raw Scores: 2312.5 each.

### 3.2 EDCA Application & Settlement
The DAG calculates the exponential decay based on cohort age at the end of Cohort 5.  

| Cohort | Age ($\Delta c_i$) | Multiplier ($r^{\Delta c_i}$) | Alice (Loyal) | Bob (Sniper) | Charlie (Late) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **C1** | 4 | $0.80^4 = 0.4096$ | 896.0 | 896.0 | 0.0 |
| **C2** | 3 | $0.80^3 = 0.5120$ | 825.6 | 0.0 | 0.0 |
| **C3** | 2 | $0.80^2 = 0.6400$ | 1048.0 | 0.0 | 0.0 |
| **C4** | 1 | $0.80^1 = 0.8000$ | 1410.0 | 0.0 | 0.0 |
| **C5** | 0 | $0.80^0 = 1.0000$ | 2312.5 | 2312.5 | 2312.5 |
| **Total Weight** | | | **6492.1** | **3208.5** | **2312.5** |


**Final Payout of the $4.625$ BTC Block Reward:**
* **Alice ($54.04%$):** Receives $2.500$ BTC.
* **Bob ($26.71%$):** Receives $1.235$ BTC.
* **Charlie ($19.25%$):** Receives $0.890$ BTC.

Outcome: The game theory strictly enforces fairness even under realistic fee fluctuations. Bob's attempt to snipe the $1.50$ BTC fee spike failed; because his historical absence allowed his earlier score to decay, he only secured $26.7%$ of the block. Alice captured the absolute majority ($54%$) of the block by grinding through the low-fee periods, actively being rewarded for pool loyalty. Charlie received exact, un-diluted Expected Value (EV) corresponding to the high-fee work he just submitted. One thing to notice here is that the value of $r$ is $0.80$, which is quite aggressive in this case, but in an actual environment, a value higher than $r = 0.9$ is suggested to stop burning the share or work of miners too quickly.

## 4. Block-Settled EDCA vs. Rosenfeld’s Geometric Method 
To validate the academic and architectural necessity of Block-Settled EDCA, its mechanics must be fundamentally contrasted with the classical scoring framework established by Meni Rosenfeld. While both systems utilize an asymptotic exponential decay curve to nullify the economic incentives of pool-hopping, Rosenfeld’s Geometric Method [1] was structurally designed for a linear sharechain paradigm (a traditional blockchain structure). Block-Settled EDCA, conversely, re-engineers this mathematical ideal to survive within an asynchronous, concurrent Directed Acyclic Graph (DAG) consensus model.

### 4.1 Coordinate Space and Total Ordering Constraints 
The primary divergence between the two architectures lies in the coordinate space used to calculate the decay exponent. Rosenfeld’s Geometric Method [1] tracks state transitions based on a strict, sequential index of individual shares, denoted as $s_1, s_2, s_3 \dots$. This methodology assumes a strict linear progression of shares, akin to a standard blockchain, where the data structure itself enforces a total ordering of work. When a share is appended to a linear chain, it is assigned a unique, unarguable chronological index, and the global counter $s$ is incremented by the decay rate $r$, where $s = sr$.In a peer-to-peer DAG network like Braidpool, concurrent share generation (beads) makes absolute total ordering mathematically impossible due to geographic network latency. If separate nodes receive parallel beads in different chronological sequences, they will apply mismatched decay exponents, resulting in divergent calculations of the global state and causing an unrecoverable split in the network's consensus.Block-Settled EDCA solves this fundamental constraint by abandoning the individual, linear share index as an independent variable. Instead of decaying work per individual share, the protocol utilizes graph cuts to establish macroscopic consensus boundaries across the asynchronous DAG. The parallel beads bounded between these graph cuts are grouped into uniform topological structures known as cohorts. EDCA applies the decay factor $r$ exclusively when a cohort boundary closes. Consequently, every concurrent bead residing within the same cohort is assigned the identical topological age ($\Delta c_i$), meaning all parallel shares are diluted uniformly. By shifting the decay coordinate from a linear, sequential share index to a topological cohort interval, EDCA converts a linear mathematical curve into a deterministic, DAG-compatible protocol rule.

### 4.2 Temporal Boundaries and Counterparty Risk Abstraction
The secondary distinction involves the handling of temporal boundaries and the absorption of economic variance. Rosenfeld’s Geometric Method is explicitly round-based, defining its boundaries by the time elapsed between one block found by the pool and the next. To prevent pool-hoppers from exploiting the increased value of young rounds, the geometric method [1] introduces a "variable fee" ($c$) alongside a fixed fee ($f$). At the genesis of a new round, the system initializes by granting an infinite history of virtual shares, mathematically expressed as:$$\sum_{i=-\infty}^{0} r^{i-1}pB = \frac{pB}{r-1}$$This initialization ensures that a steady state is maintained, as any incoming miner always sees an infinite sequence of decaying history behind them. However, this framework demands that a coordinating entity act as a financial counterparty, absorbing massive variance and taking substantial financial risk during extended, unlucky rounds.Because a decentralized DAG network lacks a central treasury or coordinating entity to absorb this risk, Block-Settled EDCA completely removes the concept of round boundaries and virtual shares. The exponential decay curve under EDCA functions continuously, passing uninterrupted through block discovery events. When a Braidpool miner successfully uncovers a valid Bitcoin block, the event does not reset or erase the historical scores of the pool participants. Instead, the block discovery acts purely as a liquidity settlement trigger for the existing Unspent Hash Power Output (UHPO) state. Payout percentages are computed directly from the active, decayed weights at that exact moment in topological history, eliminating the need for a risk-bearing counterparty.

### 4.3 Consensus State Space and Memory Exhaustion Vectors
The final divergence addresses the long-term management of the consensus state space. In Rosenfeld’s linear implementation, the global score variable $s$ grows exponentially as a round progresses. Rosenfeld notes that this metric will inevitably overflow standard machine memory bounds if implemented naively, and proposes mitigating this by periodically dividing all worker scores by the current value of $s$ ($S_{k} = \frac{S_{k}}{s}$) or by maintaining the entire system on a complex logarithmic scale.While a single coordinating node on a linear chain can execute arbitrary state rescaling to manage this bloat, a decentralized DAG consensus network cannot tolerate non-deterministic or uncoordinated state alterations. Furthermore, a pure geometric series mathematically approaches, but never perfectly reaches, zero. Storing an infinite history of marginal share weights would cause the distributed ledger to experience unbounded state-bloat, introducing a severe memory-exhaustion Denial-of-Service (DoS) vector.Block-Settled EDCA mitigates both the overflow and state-bloat vulnerabilities by enforcing a strict protocol-level truncation window ($k$). Any historical cohort that ages beyond the threshold of $k$ cohorts is cleanly pruned from the active DAG ledger. Because the decay multiplier at the boundary of $k$ resolves to negligible value, this truncation eliminates the state-bloat threat without altering the economic incentives of the pool. This restriction bounds the active state matrix to a strict $O(1)$ memory footprint, allowing the consensus parameters to be safely validated across all peer nodes using deterministic, fixed-point integer bitwise shifts.

**Note:** I started working on my approach without looking or knowing about the details of the existing algorithms like PPLNS, Shift-PPLNS, and geometric methods [1]. And when I finished up creating this new approach, I found out that similar-sounding approaches already exist. So later on, I conducted a detailed comparison between the existing and this approach I derived independently. The above-listed points are the result of the comparison between two approaches.

## 5. Systems Architecture
Translating continuous mathematics into a decentralized, consensus-critical codebase introduces distinct engineering challenges. The Braidpool node implementation enforces two strict systemic boundaries to guarantee performance and security.

### 5.1 State-Bloat and the O(1) Memory Bound
A vulnerability of pure exponential decay is that historical scores theoretically approach, but never reach, zero. In a network maintaining UTXO-like hash-power sets, storing infinite work history enables memory exhaustion (DoS) attacks.

Braidpool introduces a rigid truncation window $(k)$. By establishing a deterministic protocol rule (e.g., $k=5000$ cohorts), any bead aging beyond the threshold is safely pruned. Because the table multiplier at $k=5000$ resolves to cryptographic dust, the economic impact is mathematically nullified while ensuring the state's memory footprint remains strictly $O(1)$.

### 5.2 Safe Fixed-Point Arithmetic in Rust
To prevent chain-splits across varying machine architectures, floating-point math is strictly prohibited in Braidpool consensus. EDCA decay is pre-computed into an $O(1)$ lookup table initialized using strict fixed-point bitwise shifts (e.g., $1u128 << 64$).

Furthermore, extreme transaction fee anomalies introduce integer saturation risks. If high-value raw scores are multiplied by fractional shift tables directly $(raw_score * multiplier >> 64)$, the intermediate integer can silently overflow standard 128-bit memory constraints, artificially capping the score of large miners and destroying Sybil resistance. Braidpool mitigates this using a distributive split-shift algorithm, calculating the high and low 64-bit segments independently to guarantee mathematical fidelity under limitless fee spikes.

### 5.3 On-Chain Settlement and Dust Redistribution
Because EDCA relies on an exponential decay curve, historical cohort weights theoretically approach zero over time. This introduces a strict base-layer constraint during block template construction: a miner's calculated payout percentage ($P_m$) may map to a raw Bitcoin value that falls below the Bitcoin network's standard dust limit ($L_{dust}$). Since Bitcoin nodes reject transactions containing sub-dust UTXOs, these outputs cannot be included in the Braidpool coinbase transaction.

To prevent value destruction and maintain strict zero-sum settlement, Braidpool executes a deterministic dust aggregation and redistribution sweep prior to finalizing the block template. Let $A_{total}$ represent the total block reward to be distributed, and $L_{dust}$ represent the current Bitcoin network dust limit. The nominal output value ($O_m$) for any miner $m$ is initially calculated as:

$$O_m = P_m \times A_{total}$$

The network categorizes all miners into two mutually exclusive sets: the dust set ($M_{dust}$) where $O_m < L_{dust}$, and the active qualifying set ($M_{active}$) where $O_m \ge L_{dust}$.

Step 1: Dust Aggregation The protocol strips the sub-dust outputs from the payout roster and aggregates them into a single total dust pool ($D_{total}$):

$$D_{total} = \sum_{k \in M_{dust}} O_k$$

Step 2: Proportional Redistribution This aggregated value ($D_{total}$) is not claimed as a fee by the block finder; instead, it is redistributed exclusively among the qualifying miners ($q \in M_{active}$). The dust is allocated in direct proportion to their existing valid consensus weight. The final, adjusted on-chain payout ($O'_q$) for a qualifying miner $q$ is defined as:

$$O'_q = O_q + \left( \frac{O_q}{\sum_{j \in M_{active}} O_j} \times D_{total} \right)$$

This mechanism guarantees that 100% of the block reward is trustlessly settled to active contributors on-chain. Marginal hashrate that has decayed below the economic threshold of the Bitcoin base layer is systematically swept and awarded to the miners sustaining the current DAG consensus, enforcing total economic efficiency.


## 6. Conclusion
Block-Settled EDCA transforms decentralized mining from a theoretical ideal into a strictly rational economic enterprise. By intertwining DAG topological boundaries with exponential decay and dynamic fee amplification, Braidpool mathematically eradicates the profitability of pool-hopping, ensuring that geographic latency and network transaction volatility can no longer be weaponized against honest miners.

## 7. References

1. Rosenfeld, M. (2011). *Analysis of Bitcoin Pooled Mining Reward Systems*. [arXiv preprint](https://arxiv.org/abs/1112.4980)