import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

-- Definition: EDCA geometric score function
noncomputable def miner_score (r : ℝ) (batches : ℕ) (work : ℝ) : ℝ :=
  work * ((1 - r^batches) / (1 - r))

-- Helper 1: Explicitly define the sum of a list of workloads
-- (Marked noncomputable because Real number addition carries infinite precision)
noncomputable def total_work : List ℝ → ℝ
  | []        => 0
  | w :: ws   => w + total_work ws

-- Helper 2: Explicitly define the sum of individual EDCA scores for a list
-- (Marked noncomputable because it depends on miner_score)
noncomputable def total_score (r : ℝ) (batches : ℕ) : List ℝ → ℝ
  | []        => 0
  | w :: ws   => miner_score r batches w + total_score r batches ws

-- Theorem 1: Base linearity for a 2-split partition
-- Verifies the distributive property of multiplication over addition.
theorem braidpool_is_sybil_resistant 
  (r : ℝ) (batches : ℕ) (work_A work_B : ℝ) : 
  miner_score r batches work_A + miner_score r batches work_B = 
  miner_score r batches (work_A + work_B) := by
  
  unfold miner_score
  ring

-- Theorem 2: Generalized linearity for N-split partition (via List Induction)
-- Proves that splitting hashrate across an entire list of N identities 
-- equals the score of their combined hashrate.
theorem braidpool_sybil_resistant_n_splits
  (r : ℝ) (batches : ℕ) (work_list : List ℝ) : 
  total_score r batches work_list = miner_score r batches (total_work work_list) := by
  
  -- We prove this for an arbitrary list length using induction
  induction work_list with
  | nil =>
    -- Base Case: An empty list of miners yields 0 score and 0 work
    unfold total_score total_work miner_score
    ring
  | cons w ws ih =>
    -- Inductive Step: If it works for a list of size N (ih), it works for N + 1
    unfold total_score total_work
    rw [ih]
    unfold miner_score
    ring
