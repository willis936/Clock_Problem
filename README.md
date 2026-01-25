# Clock Problem

**When are all three hands of a 12-hour analog clock equally spaced (120° apart)?**

## Answer: Never

There is no time—not even in complex time—when the hour, minute, and second hands are exactly 120° apart from each other.

## History:

I came up with this problem in 2012 when I was an undergrad.  It was good for inspiring mathematical thinking among friends.

I set up the relationships by hand and wrote C and MATLAB code to brute force the near misses.  I uploaded my work in 2017.

In 2026 I went back to it to give it a final cleanup pass using LLMs for prettifying and documentation.


## Interactive Visualization

**[Interactive Clock Simulator](https://willis936.github.io/Clock_Problem/)**

Or open `clock_visualizer.html` locally in your browser.

## Files

- `clock_problem.py` - Analytical solution and near-miss calculator
- `clock_visualizer.html` - Interactive browser-based visualization
- `README.md` - This file

## Usage

```bash
# Run the analysis
python clock_problem.py

# Or import as a module
from clock_problem import get_best_near_misses, prove_no_solution
```

## Mathematical Proof

### Hand Positions

At time $t$ seconds from 12:00:00:

| Hand | Angular Position | Angular Velocity |
|------|------------------|------------------|
| Hour | $H(t) = \frac{t}{120}°$ | $\frac{1}{120}$ °/s |
| Minute | $M(t) = \frac{t}{10}°$ | $\frac{1}{10}$ °/s |
| Second | $S(t) = 6t°$ | $6$ °/s |

### Relative Positions

$$M - H = \frac{11t}{120}° \quad \text{(minute relative to hour)}$$

$$S - H = \frac{719t}{120}° \quad \text{(second relative to hour)}$$

## Deriving the Equation

**1. Angular Velocities (Degrees per second)**
- Hour Hand ($v_h$): $1/120$ deg/s
- Minute Hand ($v_m$): $1/10$ deg/s
- Second Hand ($v_s$): $6$ deg/s

**2. Relative Velocities (Relative to Hour Hand)**
- Minute-Hour speed: $v_m - v_h = \frac{1}{10} - \frac{1}{120} = \frac{11}{120}$ deg/s
- Second-Hour speed: $v_s - v_h = 6 - \frac{1}{120} = \frac{719}{120}$ deg/s

**3. The Condition for Equal Spacing**
For the hands to be equally spaced in the order Hour-Minute-Second:
- The Minute hand must be $120^\circ$ ahead of the Hour hand (plus any number of full circles).
- The Second hand must be $240^\circ$ ahead of the Hour hand (plus any number of full circles).

Let $t$ be the time in seconds.
Let $k_1$ and $k_2$ be integers representing the number of full $360^\circ$ laps passed.

**Equation A (Minute-Hour):**
$$\frac{11}{120}t = 120 + 360k_1$$

**Equation B (Second-Hour):**
$$\frac{719}{120}t = 240 + 360k_2$$

**4. Eliminate Time ($t$)**
We solve Equation A for $t$:
$$t = \frac{120(120 + 360k_1)}{11}$$

Now substitute this $t$ into Equation B:
$$\frac{719}{120} \left[ \frac{120(120 + 360k_1)}{11} \right] = 240 + 360k_2$$

Cancel out $$120$$:
$$\frac{719(120 + 360k_1)}{11} = 240 + 360k_2$$

Multiply by $11$ to remove the fraction:
$$719(120 + 360k_1) = 11(240 + 360k_2)$$

Divide the entire equation by $120$ to simplify large numbers:
$$719(1 + 3k_1) = 11(2 + 3k_2)$$

Expand:
$$719 + 2157k_1 = 22 + 33k_2$$

Rearrange to put constants on one side and $k$ terms on the other:
$$33k_2 - 2157k_1 = 719 - 22$$

**Final Result:**
$$33k_2 - 2157k_1 = 697$$

## Why No Solution Exists

We can prove this is impossible using basic arithmetic (the "Rule of 3").

When we convert the movements of the hands into a single equation, we are looking for integer numbers ($k_1$ and $k_2$) that solve this relationship:

$$33 \times k_2 - 2157 \times k_1 = 697$$

We can simplify this by noticing that both 33 and 2157 are divisible by 3. We can factor out the 3:

$$3 \times (11 \times k_2 - 719 \times k_1) = 697$$

**Here is the contradiction:**
1. The left side is **3 multiplied by a whole number**, meaning the result *must* be divisible by 3.
2. The right side is **697**.
3. **697 is not divisible by 3**.

Because a number divisible by 3 can never equal a number that isn't, **no solution exists.** The gears of the clock simply never click into this specific position.

## Complex Time Analysis

**Q: Could solutions exist if we extend time to complex numbers ($t \in \mathbb{C}$)?**

**A: No.** Here's why.

### Setup

Represent hand positions as complex exponentials on the unit circle:

$$H(t) = e^{i\omega_H t}, \quad M(t) = e^{i\omega_M t}, \quad S(t) = e^{i\omega_S t}$$

Equal spacing requires the ratios between hands to be cube roots of unity:

$$\frac{M}{H} = e^{i \cdot 2\pi/3}, \quad \frac{S}{H} = e^{i \cdot 4\pi/3}$$

### Complex Time Decomposition

For complex time $t = \tau + i\sigma$:

$$\frac{M}{H} = \underbrace{e^{-(\omega_M - \omega_H)\sigma}}_{\text{magnitude}} \cdot \underbrace{e^{i(\omega_M - \omega_H)\tau}}_{\text{phase}}$$

This reveals two independent components:
- **Magnitude** depends only on $\sigma$ (imaginary part)
- **Phase (angle)** depends only on $\tau$ (real part)

### Why Complex Time Doesn't Help

**Case 1:** If we require hands to stay on the unit circle (physical clock), then magnitude = 1, which forces $\sigma = 0$. Time must be real.

**Case 2:** If we only care about angular spacing (phases), the imaginary part $\sigma$ doesn't appear in the phase equations at all. We get the same unsolvable equation.

### The Real Obstruction

The obstruction is **arithmetic**, not a limitation of real numbers.

The minute hand gains on the hour hand at rate 11 (in natural units).
The second hand gains on the hour hand at rate 719.

For equal spacing at the same instant, we would need:

$$\frac{719}{11} = \frac{\text{(S-H target angle)}}{\text{(M-H target angle)}} = \frac{240°}{120°} = 2$$

But $719/11 \approx 65.36 \neq 2$.

This ratio mismatch exists in any number system. Complex time, quaternions, or any other extension cannot change the fundamental incompatibility of the hand speeds.

## Complete List of Near-Misses (Chronological)

There are exactly **22 near-miss times** in each 12-hour period where the hands come closest to equal spacing. These occur in **11 symmetric pairs** around 6:00:00.

| # | Rank | Time | Total Error | Gap 1 | Gap 2 | Gap 3 |
|---|------|------|-------------|-------|-------|-------|
| 1 | 5th | 12:21:41.808 | 1.335° | 119.33° | 120.00° | 120.67° |
| 2 | 11th | 12:43:23.616 | 2.670° | 118.66° | 120.00° | 121.34° |
| 3 | 22nd | 1:26:47.232 | 5.341° | 117.33° | 120.00° | 122.67° |
| 4 | 17th | 1:49:29.124 | 4.339° | 117.83° | 120.00° | 122.17° |
| 5 | 7th | 2:32:52.740 | 1.669° | 119.17° | 120.00° | 120.83° |
| **6** | **1st** | **2:54:34.548** | **0.334°** | **119.83°** | **120.00°** | **120.17°** |
| 7 | 9th | 3:37:58.164 | 2.337° | 118.83° | 120.00° | 121.17° |
| 8 | 15th | 3:59:39.972 | 3.672° | 118.16° | 120.00° | 121.84° |
| 9 | 19th | 4:44:03.672 | 4.673° | 117.66° | 120.00° | 122.34° |
| 10 | 13th | 5:05:45.480 | 3.338° | 118.33° | 120.00° | 121.67° |
| 11 | 3rd | 5:49:09.096 | 0.668° | 119.67° | 120.00° | 120.33° |
| 12 | 4th | 6:10:50.904 | 0.668° | 119.67° | 120.00° | 120.33° |
| 13 | 14th | 6:54:14.520 | 3.338° | 118.33° | 120.00° | 121.67° |
| 14 | 20th | 7:15:56.328 | 4.673° | 117.66° | 120.00° | 122.34° |
| 15 | 16th | 8:00:20.028 | 3.672° | 118.16° | 120.00° | 121.84° |
| 16 | 10th | 8:22:01.836 | 2.337° | 118.83° | 120.00° | 121.17° |
| **17** | **2nd** | **9:05:25.452** | **0.334°** | **119.83°** | **120.00°** | **120.17°** |
| 18 | 8th | 9:27:07.260 | 1.669° | 119.17° | 120.00° | 120.83° |
| 19 | 18th | 10:10:30.876 | 4.339° | 117.83° | 120.00° | 122.17° |
| 20 | 21st | 10:33:12.768 | 5.341° | 117.33° | 120.00° | 122.67° |
| 21 | 12th | 11:16:36.384 | 2.670° | 118.66° | 120.00° | 121.34° |
| 22 | 6th | 11:38:18.192 | 1.335° | 119.33° | 120.00° | 120.67° |

### Observations

1. **Every near-miss has one gap of exactly 120.00°** — the error comes entirely from the other two gaps being equally offset above and below 120°.

2. **Symmetric pairs**: Times $t$ and $(43200 - t)$ seconds have identical error values. Here is the complete list of all 11 pairs, ordered by accuracy:
   - **02:54:34 ↔ 09:05:25** (0.334°)
   - **05:49:09 ↔ 06:10:50** (0.668°)
   - **00:21:41 ↔ 11:38:18** (1.335°)
   - **02:32:52 ↔ 09:27:07** (1.669°)
   - **03:37:58 ↔ 08:22:01** (2.337°)
   - **00:43:23 ↔ 11:16:36** (2.670°)
   - **05:05:45 ↔ 06:54:14** (3.338°)
   - **03:59:39 ↔ 08:00:20** (3.672°)
   - **01:49:29 ↔ 10:10:30** (4.339°)
   - **04:44:03 ↔ 07:15:56** (4.673°)
   - **01:26:47 ↔ 10:33:12** (5.341°)

3. **The two best times** (02:54:34.548 and 09:05:25.452) have hands that are at most **0.17° away** from perfect 120° spacing — less than 1/2000th of a full rotation.

4. **Exact fractional representation** of the best near-misses:

   $$t_1 = \frac{2{,}505{,}600}{719} \text{ seconds} = \text{02:54:34.548...}$$

   $$t_2 = \frac{7{,}833{,}600}{719} \text{ seconds} = \text{09:05:25.452...}$$

### Closed-Form Formula

Near-misses where the second-hour gap is exactly 120° occur at:

$$t = \frac{14400(1 + 3k)}{719} \text{ seconds}, \quad k = 0, 1, 2, \ldots$$

## Bonus: Alternative Clock Designs

The impossibility of equal spacing is **not universal**—it's specific to our 12/60/60 system. Different clock ratios can allow perfect equal spacing.

### The General Condition

For a clock where:
- The minute hand completes $m$ rotations per hour-hand rotation
- The second hand completes $s$ rotations per minute-hand rotation

**Solutions exist if and only if:**

$$m(s - 2) \equiv 2 \pmod{3}$$

This requires:
- $m \equiv 1 \pmod 3$ and $s \equiv 1 \pmod 3$, OR
- $m \equiv 2 \pmod 3$ and $s \equiv 0 \pmod 3$

**Crucially, $m$ cannot be divisible by 3.** Since our standard clock has $m = 12$ (divisible by 3), no choice of $s$ can fix it.

### Clocks That Would Work

| Clock Type | Minutes/Hour | Seconds/Minute | Equal Spacing? |
|------------|--------------|----------------|----------------|
| Standard | 12 | 60 | ❌ Impossible |
| Base-4 | 4 | 4 | ✅ Possible |
| Decimal (French Revolutionary) | 10 | 100 | ✅ Possible |
| Octal | 8 | 9 | ✅ Possible |

### Example: Base-4 Clock

With $m = 4$ and $s = 4$, equal spacing occurs when the hour hand is at **40°**:

| Hand | Position |
|------|----------|
| Hour | 40° |
| Minute | 160° |
| Second | 280° |

**All three gaps are exactly 120°.**

### Why 12 Fails

The number 12 being divisible by 3 creates an arithmetic obstruction that cannot be overcome by any choice of seconds-per-minute. If we had adopted a **decimal time system** (like the French briefly tried in the 1790s), the "clock problem" would have an exact solution.

