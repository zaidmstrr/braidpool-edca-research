import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

-- Definition: EDCA geometric score function using inverse multiplication
-- Inverse notation (⁻¹) ensures computational compatibility with the ring solver.
noncomputable def miner_score (r : ℝ) (batches : ℕ) (work : ℝ) : ℝ :=
  work * (1 - r^batches) * (1 - r)⁻¹

-- Theorem: Opportunity Cost Equivalence
-- Asserts that subtracting the evaluation of (batches - 1) from the base evaluation
-- yields an exact proportional equivalence to the single excluded batch multiplier.
theorem mev_snipe_opportunity_cost 
  (r : ℝ) (batches : ℕ) (work B_base F_high : ℝ) :
  miner_score r batches work * (B_base + F_high) 
  - miner_score r (batches - 1) work * (B_base + F_high) 
  = work * (r^(batches - 1) - r^batches) * (1 - r)⁻¹ * (B_base + F_high) := by
  
  unfold miner_score
  ring