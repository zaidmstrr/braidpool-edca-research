import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

-- Definition: Single independent topological share value
noncomputable def share_value (r : ℝ) (age : ℕ) (work : ℝ) : ℝ :=
  work * r^age

-- Theorem: Strict inequality of topological delay
-- Asserts that artificially increasing the exponent (age + delay)
-- yields a strictly lesser valuation when the base (r) is bounded strictly between 0 and 1.
theorem share_withholding_is_punished
  (r : ℝ) (hr1 : 0 < r) (hr2 : r < 1)         -- Base condition: 0 < r < 1
  (work : ℝ) (h_work : 0 < work)              -- Scalar condition: strictly positive work
  (age delay : ℕ) (h_delay : 0 < delay) :     -- Exponent condition: strictly positive delay
  share_value r age work > share_value r (age + delay) work := by
  
  unfold share_value
  
  -- Sub-proof 1: Establish the strict inequality of the topological exponents
  have h_age_lt : age < age + delay := by linarith
  
  -- Sub-proof 2: Apply the fractional exponent rule for bases < 1
  have h_pow_lt : r^(age + delay) < r^age := by 
    exact pow_lt_pow_right_of_lt_one₀ hr1 hr2 h_age_lt
    
  -- Sub-proof 3: Non-linear arithmetic resolution using the established bounds
  nlinarith [h_pow_lt, h_work]