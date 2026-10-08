"""Stage 1: prescribed-stress creep material point, Ragab et al. (2024).

Run: python ragab2024_material_point.py
Requires: numpy. Optional plots: add --plot (requires matplotlib).

Units: stress MPa, time hours, strain dimensionless, work MPa = N/mm^2.
Source: DOI 10.1016/j.engfracmech.2024.110491, Eqs. 11-14, 26-27,
Table 2. P91 at 650 C. No time-hardening or damage acceleration of Norton.

This is NOT the full phase-field model and D=1 is NOT a prediction of
structural fracture time. No plasticity, elasticity solve, stiffness loss,
phase-field PDE, or spatial stress redistribution is included here.
At this stage sigma == sigma_prime: the input is a prescribed, symmetric
3D stress tensor in an undegraded material. That convention must be revisited
when coupling to d. No Poisson ratio or hardening law is assumed.

Cocks-Ashby is restricted here to nonnegative mean stress. At eta=0 its
infinite-ductility limit gives zero damage rate. Pure hydrostatic stress
produces no J2 creep in this model, not a general claim about cavitation.

The step function is PURE: call repeatedly from the same committed state
during FE iterations; commit the returned state only after convergence.
"""

from dataclasses import dataclass
from pathlib import Path
import argparse
import csv
import numpy as np


@dataclass(frozen=True)
class Material:
    A: float = 1.762e-14  # MPa^(-n) / hour, Table 2
    n: float = 5.58
    eps_f: float = 0.28
    Gc: float = 100.0  # N/mm; monitor only, no phase-field evolution
    beta0: float = 0.01
    v: float = 1.0

    def __post_init__(self):
        vals = [self.A, self.n, self.eps_f, self.Gc, self.beta0, self.v]
        if not np.all(np.isfinite(vals)):
            raise ValueError("Material parameters must be finite.")
        if not (self.A > 0 and self.n > 0.5 and self.eps_f > 0
                and self.Gc > 0 and 0 < self.beta0 < 1 and self.v > 0):
            raise ValueError("Invalid material parameters.")


@dataclass(frozen=True)
class State:
    time: float
    eps_cr: np.ndarray
    eps_eq: float
    D: float
    work_cr: float


def initial_state():
    return State(0.0, np.zeros((3, 3)), 0.0, 0.0, 0.0)


def invariants(sigma):
    sigma = np.asarray(sigma, dtype=float)
    if sigma.shape != (3, 3) or not np.all(np.isfinite(sigma)):
        raise ValueError("Stress must be a finite 3x3 tensor, in MPa.")
    if not np.allclose(sigma, sigma.T, rtol=0, atol=1e-12):
        raise ValueError("Stress tensor must be symmetric.")
    mean = float(np.trace(sigma) / 3)
    s = sigma - mean * np.eye(3)
    seq = float(np.sqrt(1.5 * np.sum(s * s)))
    return sigma, mean, s, seq


def rates(sigma, mat=Material()):
    """Return tensor creep rate, equivalent rate, damage rate, creep power.

    Damage is computed using the inverse ductility factor, avoiding a
    division by sinh(0) at zero triaxiality.
    """
    sigma, mean, s, seq = invariants(sigma)
    if mean < -1e-12:
        raise ValueError("Compressive mean stress is outside this demo's domain.")
    if seq <= 1e-12:
        return np.zeros((3, 3)), 0.0, 0.0, 0.0
    eta = max(mean, 0.0) / seq
    a = (mat.n - 0.5) / (mat.n + 0.5)
    with np.errstate(over="raise", invalid="raise"):
        req = mat.A * seq ** mat.n
        eps_dot = 1.5 * req * s / seq
        inv_ductility_factor = np.sinh(2 * a * eta) / np.sinh(2 * a / 3)
        D_dot = req * inv_ductility_factor / mat.eps_f
        power = float(np.sum(sigma * eps_dot))
    if not np.all(np.isfinite([req, D_dot, power])):
        raise ValueError("Rates overflow; inspect stress and units.")
    return eps_dot, req, float(D_dot), power


def beta(D, mat=Material()):
    if not np.isfinite(D) or not 0 <= D <= 1:
        raise ValueError("D must be in [0, 1]. Stop at ductility exhaustion.")
    return (1 - mat.beta0) * (1 - D) ** mat.v + mat.beta0


def trial_step(old, sigma_start, sigma_end, dt, mat=Material()):
    """Trapezoidal integration along a PRESCRIBED stress history.

    No in-place state changes, no silent clipping of D. If a trial exceeds
    D=1, reduce dt or stop. This is not an implicit FE constitutive solver.
    """
    if not np.isfinite(dt) or dt <= 0:
        raise ValueError("dt must be positive, in hours.")
    beta(old.D, mat)
    r0, r1 = rates(sigma_start, mat), rates(sigma_end, mat)
    de, deq, dD, dw = [0.5 * dt * (a + b) for a, b in zip(r0, r1)]
    newD = old.D + dD
    if newD > 1:
        raise ValueError("Trial crosses D=1; reduce dt or end this stage.")
    return State(old.time + dt, old.eps_cr + de,
                 old.eps_eq + deq, newD, old.work_cr + dw)


def uniaxial(sigma):
    return np.diag([float(sigma), 0.0, 0.0])


def integrate(stress_history, end_time, steps, mat=Material()):
    if not np.isfinite(end_time) or end_time <= 0 or steps < 1:
        raise ValueError("Need positive duration and at least one step.")
    times = np.linspace(0, end_time, steps + 1)
    states = [initial_state()]
    for t0, t1 in zip(times[:-1], times[1:]):
        states.append(trial_step(states[-1], stress_history(t0),
                                 stress_history(t1), t1 - t0, mat))
    return states


def verify(mat=Material()):
    """Independent analytic checks; raises if any verification fails."""
    # Uniaxial constant stress: all components, damage and work have closed forms.
    stress, duration = 82.0, 24.0
    hist = integrate(lambda t: uniaxial(stress), duration, 48, mat)
    e = mat.A * stress ** mat.n * duration
    expected = np.diag([e, -e / 2, -e / 2])
    np.testing.assert_allclose(hist[-1].eps_cr, expected, rtol=1e-12, atol=1e-15)
    np.testing.assert_allclose(hist[-1].D, e / mat.eps_f, rtol=1e-12)
    np.testing.assert_allclose(hist[-1].work_cr, stress * e, rtol=1e-12)
    assert abs(np.trace(hist[-1].eps_cr)) < 1e-14
    assert all(a.D <= b.D for a, b in zip(hist[:-1], hist[1:]))
    # Hydrostatic addition leaves Norton creep unchanged, increases tensile damage.
    r_low = rates(uniaxial(stress), mat)
    r_high = rates(uniaxial(stress) + 40 * np.eye(3), mat)
    np.testing.assert_allclose(r_high[0], r_low[0], rtol=1e-12, atol=1e-15)
    assert r_high[2] > r_low[2]
    # A pure trial update must not alter committed history or accumulate twice.
    old = initial_state()
    a = trial_step(old, uniaxial(stress), uniaxial(stress), 1, mat)
    b = trial_step(old, uniaxial(stress), uniaxial(stress), 1, mat)
    assert old.D == 0 and np.count_nonzero(old.eps_cr) == 0
    np.testing.assert_array_equal(a.eps_cr, b.eps_cr)
    # Nonconstant load: linear stress ramp has an independent analytic integral.
    s0, s1, T = 60.0, 100.0, 24.0
    exact_e = mat.A * T * (s1 ** (mat.n + 1) - s0 ** (mat.n + 1)) / (
        (mat.n + 1) * (s1 - s0))
    exact_w = mat.A * T * (s1 ** (mat.n + 2) - s0 ** (mat.n + 2)) / (
        (mat.n + 2) * (s1 - s0))
    convergence = []
    for N in [12, 24, 48, 96]:
        result = integrate(lambda t: uniaxial(s0 + (s1 - s0) * t / T), T, N, mat)[-1]
        err_e = abs(result.eps_eq / exact_e - 1)
        err_w = abs(result.work_cr / exact_w - 1)
        np.testing.assert_allclose(result.D, result.eps_eq / mat.eps_f, rtol=1e-12)
        convergence.append((N, err_e, err_w))
    for previous, current in zip(convergence[:-1], convergence[1:]):
        assert 3.8 < previous[1] / current[1] < 4.2
        assert 3.8 < previous[2] / current[2] < 4.2
    # Limiting states and unsupported compressive loading.
    assert rates(np.zeros((3, 3)), mat)[2] == 0
    assert rates(np.diag([50.0, -50.0, 0.0]), mat)[2] == 0
    try:
        rates(-uniaxial(82), mat)
    except ValueError:
        pass
    else:
        raise AssertionError("Compressive mean stress should be rejected.")
    print("PASS: constant stress, tensor invariants, triaxiality, state isolation,")
    print("      loading limits and second-order ramp convergence.")
    print("Ramp convergence: steps, relative strain error, relative work error")
    for row in convergence:
        print(f"{row[0]:4d}  {row[1]:.6e}  {row[2]:.6e}")
    return hist


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stress", type=float, default=82.0, help="uniaxial tensile MPa")
    parser.add_argument("--hours", type=float, default=24.0)
    parser.add_argument("--steps", type=int, default=48)
    parser.add_argument("--output", type=Path, default=Path("material_point.csv"))
    parser.add_argument("--plot", action="store_true")
    args = parser.parse_args()
    if args.stress <= 0:
        parser.error("--stress must be positive")
    mat = Material()
    verify(mat)
    states = integrate(lambda t: uniaxial(args.stress), args.hours, args.steps, mat)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["time_h", "eps_cr_11", "eps_cr_22", "eps_cr_33",
                         "eps_eq_cr", "D", "work_cr_MPa", "beta", "Gc_eff_N_per_mm"])
        for state in states:
            writer.writerow([state.time, *np.diag(state.eps_cr), state.eps_eq,
                             state.D, state.work_cr, beta(state.D, mat),
                             mat.Gc * beta(state.D, mat)])
    last = states[-1]
    print(f"P91 650 C; stress={args.stress:g} MPa; duration={args.hours:g} h")
    print(f"eps_eq_cr={last.eps_eq:.8g}; D={last.D:.8g}; work={last.work_cr:.8g} MPa")
    print(f"Gc_eff={mat.Gc * beta(last.D, mat):.8g} N/mm (monitor only)")
    print(f"CSV: {args.output.resolve()}")
    if args.plot:
        import matplotlib.pyplot as plt
        fig, axes = plt.subplots(1, 3, figsize=(12, 3.5), constrained_layout=True)
        times = [s.time for s in states]
        values = [[s.eps_eq for s in states], [s.D for s in states],
                  [mat.Gc * beta(s.D, mat) for s in states]]
        labels = ["Equivalent creep strain", "Creep damage D", "Gc_eff [N/mm]"]
        for ax, y, label in zip(axes, values, labels):
            ax.plot(times, y)
            ax.set(xlabel="Time [h]", ylabel=label)
            ax.grid(alpha=0.3)
        figure_path = args.output.with_suffix(".png")
        fig.savefig(figure_path, dpi=160)
        print(f"Plot: {figure_path.resolve()}")


if __name__ == "__main__":
    main()
