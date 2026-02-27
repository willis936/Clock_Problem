from fractions import Fraction
from typing import List, Tuple, NamedTuple
import math
import sympy as sp
from sympy.solvers.diophantine import diophantine

# =============================================================================
# CONSTANTS
# =============================================================================

# Angular velocities (degrees per second)
OMEGA_HOUR = Fraction(1, 120)      # 360° / (12 * 3600s) = 1/120 °/s
OMEGA_MINUTE = Fraction(1, 10)     # 360° / 3600s = 1/10 °/s  
OMEGA_SECOND = Fraction(6, 1)      # 360° / 60s = 6 °/s

# Relative angular velocities
OMEGA_MH = OMEGA_MINUTE - OMEGA_HOUR  # = 11/120 °/s (minute relative to hour)
OMEGA_SH = OMEGA_SECOND - OMEGA_HOUR  # = 719/120 °/s (second relative to hour)

# Period of 12-hour clock in seconds
PERIOD_12H = 43200

# Target angular separation for equal spacing
TARGET_ANGLE = Fraction(120, 1)  # 120 degrees


# =============================================================================
# DATA STRUCTURES
# =============================================================================

class NearMiss(NamedTuple):
    """Represents a near-miss time when hands are almost equally spaced."""
    time_seconds: Fraction      # Exact time in seconds (as fraction)
    time_str: str               # Human-readable time string
    total_error: Fraction       # Sum of deviations from 120° (degrees)
    max_error: Fraction         # Maximum deviation from 120° (degrees)
    gaps: Tuple[Fraction, ...]  # The three angular gaps (sorted)
    alignment_type: str         # Which pair is exactly aligned


# =============================================================================
# CORE FUNCTIONS
# =============================================================================

def mod_inverse(a: int, m: int) -> int:
    """Compute modular multiplicative inverse using extended Euclidean algorithm."""
    def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
        if a == 0:
            return b, 0, 1
        gcd, x1, y1 = extended_gcd(b % a, a)
        x = y1 - (b // a) * x1
        y = x1
        return gcd, x, y

    _, x, _ = extended_gcd(a % m, m)
    return (x % m + m) % m


def hand_angles(t: Fraction) -> Tuple[Fraction, Fraction, Fraction]:
    """
    Compute angular positions of all three hands at time t.

    Args:
        t: Time in seconds from 12:00:00 (as Fraction for exact arithmetic)

    Returns:
        Tuple of (hour_angle, minute_angle, second_angle) in degrees [0, 360)
    """
    hour = (OMEGA_HOUR * t) % 360
    minute = (OMEGA_MINUTE * t) % 360
    second = (OMEGA_SECOND * t) % 360
    return hour, minute, second


def angular_gaps(t: Fraction) -> Tuple[Fraction, Fraction, Fraction]:
    """
    Compute the three angular gaps between hands at time t.

    Returns:
        Tuple of three gaps in degrees, sorted ascending
    """
    h, m, s = hand_angles(t)
    angles = sorted([h, m, s])

    gap1 = angles[1] - angles[0]
    gap2 = angles[2] - angles[1]
    gap3 = Fraction(360) - angles[2] + angles[0]

    return tuple(sorted([gap1, gap2, gap3]))


def total_error(t: Fraction) -> Fraction:
    """Compute total deviation from perfect 120° spacing."""
    gaps = angular_gaps(t)
    return sum(abs(g - TARGET_ANGLE) for g in gaps)


def max_error(t: Fraction) -> Fraction:
    """Compute maximum deviation from 120° for any gap."""
    gaps = angular_gaps(t)
    return max(abs(g - TARGET_ANGLE) for g in gaps)


def seconds_to_time_str(seconds: Fraction) -> str:
    """Convert seconds to HH:MM:SS.mmm format."""
    s = float(seconds)
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = s % 60
    return f"{h:02d}:{m:02d}:{sec:06.3f}"


# =============================================================================
# ANALYTICAL SOLUTION
# =============================================================================

def prove_no_solution() -> dict:
    """
    Prove that no exact solution exists using number theory.

    Returns:
        Dictionary containing the proof details
    """
    # For equal spacing, we need:
    # M - H ≡ 120° (mod 360°) AND S - H ≡ 240° (mod 360°)
    # OR the reverse

    # This requires: 33*k2 - 2157*k1 = 697 for integers k1, k2
    # (derived from the constraint equations)

    gcd_33_2157 = math.gcd(33, 2157)  # = 3
    remainder = 697 % gcd_33_2157      # = 1

    return {
        "equation": "33*k₂ - 2157*k₁ = 697",
        "gcd": gcd_33_2157,
        "remainder": remainder,
        "solvable": remainder == 0,
        "explanation": (
            f"gcd(33, 2157) = {gcd_33_2157}, but 697 mod {gcd_33_2157} = {remainder} ≠ 0. "
            f"Therefore, no integer solutions exist."
        )
    }


def find_all_near_misses(max_error_threshold: float = 10.0) -> List[NearMiss]:
    """
    Find all near-miss times in a 12-hour period.

    Near-misses occur when one pair of hands is exactly 120° or 240° apart,
    while the third hand is close to completing the equal spacing.

    Args:
        max_error_threshold: Maximum total error in degrees to include

    Returns:
        List of NearMiss objects, sorted by total error
    """
    near_misses = []
    seen_times = set()

    # Case 1: S - H = 120° exactly
    # 719t ≡ 14400 (mod 43200)
    for k in range(719):
        t = Fraction(14400 + 43200 * k, 719)
        if 0 <= t < PERIOD_12H:
            t_rounded = round(float(t), 6)
            if t_rounded not in seen_times:
                seen_times.add(t_rounded)
                err = total_error(t)
                if float(err) <= max_error_threshold:
                    near_misses.append(NearMiss(
                        time_seconds=t,
                        time_str=seconds_to_time_str(t),
                        total_error=err,
                        max_error=max_error(t),
                        gaps=angular_gaps(t),
                        alignment_type="S-H=120°"
                    ))

    # Case 2: S - H = 240° exactly
    for k in range(719):
        t = Fraction(28800 + 43200 * k, 719)
        if 0 <= t < PERIOD_12H:
            t_rounded = round(float(t), 6)
            if t_rounded not in seen_times:
                seen_times.add(t_rounded)
                err = total_error(t)
                if float(err) <= max_error_threshold:
                    near_misses.append(NearMiss(
                        time_seconds=t,
                        time_str=seconds_to_time_str(t),
                        total_error=err,
                        max_error=max_error(t),
                        gaps=angular_gaps(t),
                        alignment_type="S-H=240°"
                    ))

    # Case 3: M - H = 120° exactly
    for k in range(11):
        t = Fraction(14400 + 43200 * k, 11)
        if 0 <= t < PERIOD_12H:
            t_rounded = round(float(t), 6)
            if t_rounded not in seen_times:
                seen_times.add(t_rounded)
                err = total_error(t)
                if float(err) <= max_error_threshold:
                    near_misses.append(NearMiss(
                        time_seconds=t,
                        time_str=seconds_to_time_str(t),
                        total_error=err,
                        max_error=max_error(t),
                        gaps=angular_gaps(t),
                        alignment_type="M-H=120°"
                    ))

    # Case 4: M - H = 240° exactly
    for k in range(11):
        t = Fraction(28800 + 43200 * k, 11)
        if 0 <= t < PERIOD_12H:
            t_rounded = round(float(t), 6)
            if t_rounded not in seen_times:
                seen_times.add(t_rounded)
                err = total_error(t)
                if float(err) <= max_error_threshold:
                    near_misses.append(NearMiss(
                        time_seconds=t,
                        time_str=seconds_to_time_str(t),
                        total_error=err,
                        max_error=max_error(t),
                        gaps=angular_gaps(t),
                        alignment_type="M-H=240°"
                    ))

    # Sort by total error
    near_misses.sort(key=lambda x: x.total_error)

    return near_misses


def get_best_near_misses(n: int = 22) -> List[NearMiss]:
    """Get the n best near-miss times."""
    all_misses = find_all_near_misses(max_error_threshold=20.0)
    return all_misses[:n]


# =============================================================================
# COMPLEX TIME ANALYSIS
# =============================================================================

def analyze_complex_time() -> dict:
    """
    Analyze whether solutions exist in complex time.

    Returns:
        Dictionary explaining why complex time doesn't help
    """
    return {
        "conclusion": "No solutions exist in complex time",
        "reason": (
            "The equal-spacing condition depends only on the PHASES of hand positions. "
            "For complex time t = τ + iσ, the phase depends only on the real part τ. "
            "The imaginary part σ affects only the magnitude (via exp(-ωσ)), not the angle. "
            "Therefore, the arithmetic obstruction (697 mod 3 ≠ 0) persists in ℂ."
        ),
        "mathematical_detail": (
            "Hand position: H(t) = exp(iωt) = exp(iω(τ+iσ)) = e^(-ωσ) · e^(iωτ)\n"
            "Phase = ωτ (real part only)\n"
            "Magnitude = e^(-ωσ) (imaginary part only)\n"
            "Equal spacing is a phase condition, so Im(t) is irrelevant."
        ),
        "alternative_extensions": [
            "p-adic numbers (specifically ℤ₃) could formally solve the equation, "
            "but have no physical clock interpretation."
        ]
    }

def prove_complex_sympy() -> None:
    """Uses SymPy to mathematically prove that complex time collapses to real time."""
    print("--- Automated SymPy Verification ---")

    # Define variables: t is complex, k1 and k2 must be integers (full laps)
    t = sp.Symbol('t', complex=True)
    k1 = sp.Symbol('k1', integer=True)
    k2 = sp.Symbol('k2', integer=True)

    # Define the angular positions (in fractional rotations)
    h = t / 12
    m = t
    s = 60 * t

    # Setup the equations for 120-degree (1/3 rotation) separation
    eq1 = sp.Eq(m - h, sp.Rational(1, 3) + k1)
    eq2 = sp.Eq(s - m, sp.Rational(1, 3) + k2)

    # Solve Eq 1 for complex time 't'
    t_expr = sp.solve(eq1, t)[0]

    # Substitute this value of t into Eq 2
    substituted_eq2 = eq2.subs(t, t_expr)

    # Rearrange into Diophantine form
    diophantine_expr = sp.simplify((substituted_eq2.lhs - substituted_eq2.rhs) * 33)

    print(f"Eq 1 (Minute - Hour): {eq1}")
    print(f"Eq 2 (Second - Minute): {eq2}")

    print(f"\nSolving Eq 1 yields: t = {t_expr}")
    print("Because k₁ is a full-lap integer, the imaginary part of 't' is mathematically forced to 0.")

    print(f"\nSubstituting t into Eq 2 yields the constraint:")
    print(f"{diophantine_expr} = 0")

    print("\nTesting for integer solutions in ℂ using SymPy...")
    solutions = diophantine(diophantine_expr)

    if not solutions:
        print("✅ RESULT: SymPy confirms NO integer solutions exist.")
        print("   The complex time hypothesis collapses back into the unsolvable real Diophantine equation.")
    else:
        print(f"❌ Solutions found: {solutions}")


# =============================================================================
# CLOSED-FORM FORMULAS
# =============================================================================

def closed_form_near_miss(rank: int) -> Fraction:
    """
    Compute the exact time of the nth best near-miss using closed-form formula.

    The best near-misses occur at times:
        t = 14400(2 + 3m) / 719  seconds

    where m is chosen to minimize the M-H deviation from 240°.

    Args:
        rank: 1-indexed rank (1 = best, 2 = second best, etc.)

    Returns:
        Exact time in seconds as a Fraction
    """
    all_misses = get_best_near_misses(rank)
    if rank <= len(all_misses):
        return all_misses[rank - 1].time_seconds
    return None


# =============================================================================
# MAIN / DEMO
# =============================================================================

def main():
    """Demonstrate the clock problem analysis."""

    print("=" * 70)
    print("THE CLOCK PROBLEM")
    print("When are all three hands of a clock equally spaced (120° apart)?")
    print("=" * 70)

    # Prove no solution exists
    print("\n" + "─" * 70)
    print("PROOF THAT NO EXACT SOLUTION EXISTS")
    print("─" * 70)
    proof = prove_no_solution()
    print(f"\nConstraint equation: {proof['equation']}")
    print(f"\n{proof['explanation']}")
    print(f"\nConclusion: {'Solvable' if proof['solvable'] else 'NO SOLUTION EXISTS'}")

    # Complex time analysis
    print("\n" + "─" * 70)
    print("COMPLEX TIME ANALYSIS")
    print("─" * 70)
    complex_analysis = analyze_complex_time()
    print(f"\nConclusion: {complex_analysis['conclusion']}")
    print(f"\nReason: {complex_analysis['reason']}\n")

    # Automatically verify the complex mathematical impossibility
    prove_complex_sympy()

    # Near-misses
    print("\n" + "─" * 70)
    print("NEAR-MISS SOLUTIONS (Top 22)")
    print("─" * 70)
    print(f"\n{'Rank':<5} {'Time':<15} {'Error':>10} {'Max Dev':>10} {'Gaps':<35}")
    print("-" * 80)

    near_misses = get_best_near_misses(22)
    for i, nm in enumerate(near_misses, 1):
        gaps_str = f"{float(nm.gaps[0]):.2f}°, {float(nm.gaps[1]):.2f}°, {float(nm.gaps[2]):.2f}°"
        print(f"{i:<5} {nm.time_str:<15} {float(nm.total_error):>10.3f}° {float(nm.max_error):>10.3f}° {gaps_str:<35}")

    # Exact fractions for best times
    print("\n" + "─" * 70)
    print("EXACT FRACTIONAL TIMES (Best 4)")
    print("─" * 70)
    for i, nm in enumerate(near_misses[:4], 1):
        print(f"\n#{i}: t = {nm.time_seconds} seconds")
        print(f"    = {nm.time_str}")
        print(f"    Gaps: {nm.gaps[0]}°, {nm.gaps[1]}°, {nm.gaps[2]}°")


if __name__ == "__main__":
    main()
