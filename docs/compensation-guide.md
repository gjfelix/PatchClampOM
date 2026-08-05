# Understanding `Amplifiers.Compensation`

This guide explains what the four models in `PatchClamp.Amplifiers.Compensation`
actually do and why they exist. It assumes you're comfortable with
`VoltageClampAmplifier` and `PatchPipette` (see
[Getting Started](getting-started.md)) but haven't yet worked through why a
*real* voltage clamp needs correcting.

```
PatchClamp.Amplifiers.Compensation
├── PipetteCapacitanceComp     -- C-fast:  cancels the pipette glass's fast capacitive transient
├── WholeCellCapacitanceComp   -- C-slow:  cancels the membrane's slow capacitive transient
├── SeriesResistanceComp       -- R_s:     corrects the voltage error caused by R_s under current flow
└── CompensatedVClampAmp       -- all three combined into one drop-in amplifier
```

The three compensations fix three *independent* problems that all come from
the same physical fact: **the pipette is not a perfect wire.** It has
resistance and capacitance of its own, and that's what makes voltage-clamping
a real cell harder than voltage-clamping an ideal one.

> **Want each mechanism in isolation, not combined?** `Step13` (used
> throughout this guide) demonstrates all three together on one passive
> cell. Three companion examples split them apart, one per mechanism, each
> reusing the circuit from the patch-clamp workflow step where that
> compensation is actually performed in practice:
> [`Step22_PipetteCapacitanceCompensation`](../PatchClamp/Examples/Step22_PipetteCapacitanceCompensation.mo)
> (C-fast, cell-attached — before break-in), 
> [`Step23_WholeCellCapacitanceCompensation`](../PatchClamp/Examples/Step23_WholeCellCapacitanceCompensation.mo)
> (C-slow, right after break-in), and
> [`Step24_AccessResistanceCompensation`](../PatchClamp/Examples/Step24_AccessResistanceCompensation.mo)
> (R_s, same whole-cell circuit). See each model's own documentation for the
> full walkthrough and verified numbers — Step22 in particular surfaces a
> subtle point about how this amplifier model represents capacitive
> transients that's worth reading even if you only use the combined Step13.

---

## 1. Why compensation exists

`VoltageClampAmplifier` assumes the cell's membrane potential is exactly
whatever you command. In reality, the amplifier can only control the voltage
at its own headstage (`amp.p`) — the actual membrane potential is one glass
pipette away, on the far side of the pipette's resistance and capacitance:

```
  amp.p (command Vcmd,           PatchPipette                       cell.membrane_p
   amplifier measures     ┌──────────────────────────┐                (V_m, the REAL
   current here) ●────────┤                          ├────────●        membrane potential)
                 │        │                          │        │
                 │      C_pipette              R_pipette (R_s)│
                 │      (~2-5 pF,               (~3-5 MΩ)     │
                 │       "fast")                               │
                 │        │                                   ┌┴───────────┬─────────┐
                GND      GND                                  │            │         │
                                                              C_m          R_m       ...active
                                                            (10-100pF)   (leak)      channels
                                                               │            │
                                                              GND          GND (bath)
```

(This is the same pipette topology documented in `PatchPipette.mo`; the cell
side just adds `C_m`/`R_m`/channels in parallel to ground.)

This picture produces exactly three artifacts, each fixed by one of the
compensation blocks:

| # | Artifact | Cause | Fixed by |
|---|---|---|---|
| 1 | A **fast** capacitive current spike on every voltage step | `C_pipette` sits right at the headstage, charged directly by `Vcmd` — no resistor slows it down | `PipetteCapacitanceComp` (C-fast) |
| 2 | A **slow** capacitive/exponential current on every voltage step | `C_m` charges *through* `R_pipette`, so `tau_s = R_s * C_m` (tens of µs to ms) | `WholeCellCapacitanceComp` (C-slow) |
| 3 | A steady-state **voltage error**: `V_m ≠ Vcmd` whenever current flows | Ohm's law across `R_pipette`: `V_m = Vcmd - R_s * I` | `SeriesResistanceComp` (R_s) |

All three are visible simultaneously in `amp.I_raw` on a single voltage step
— they're not alternatives, they're layered on top of each other, which is
why a real amplifier has three separate knobs.

---

## 2. Worked example (the numbers `Step13_SeriesResistanceCompensation` uses)

`Step13` steps from -70 mV to -50 mV with `R_pipette = 4 MΩ`,
`C_pipette = 3 pF`, and a passive cell `C_m = 10 pF`, `R_m = 1 GΩ`. On that
step, `amp.I_raw` looks like this:

```
I_raw
  │
  │╲   <- 1) fast spike, ~C_pipette * dV/dt, decays in nanoseconds
  │ ╲
  │  ╲___
  │      ╲___              <- 2) slow exponential, tau_s = R_s*C_m = 4e6*10e-12 = 40 us
  │          ╲______________
  │                         ▔▔▔▔▔▔▔▔▔▔▔▔▔  <- 3) steady state, I_ss ~ 14.9 pA (simulated;
  │                                            not simply V_step/R_m -- PassiveCell's leak
  │                                            reversal E_L = -65 mV and R_pipette's own
  │                                            share of the divider both matter)
  └──────────────────────────────────────▶ time
     step onset
```

> **"Slow" is relative, not absolute.** 40 µs is still extremely fast in
> absolute terms — it's called "slow" only next to the pipette spike, which
> is essentially a zero-duration delta function (nothing resistively limits
> `C_pipette`, so it's over within a single simulation sample). At these
> toy-cell defaults, *both* artifacts are fully settled within ~200 µs
> (5×tau_s) — well under half a millisecond. So on any plot zoomed wider
> than a few hundred µs, they visually merge into what looks like a single
> fast blip; you have to zoom into a ~0-200 µs window right after the step
> to actually resolve them as two distinct phases. A real whole-cell
> recording (`C_m` ~ 50-200 pF) would push `tau_s` into the 0.2-1 ms range,
> clearly separated from the pipette spike.

Three numbers, three causes, three independent knobs to remove them one at a
time — that's the whole package.

---

## 3. C-fast: `PipetteCapacitanceComp`

**Cancels artifact #1** (the fast spike).

Because `C_pipette` sits directly on the command node (not filtered by
`R_pipette`), its current is just the capacitor equation applied to the
*command* voltage:

$$I_\text{comp,fast} = \text{fraction} \times C_\text{fast} \times \frac{d(V_\text{cmd})}{dt}$$

Subtract this from the raw signal and the fast spike disappears:

```
I_corrected = amp.I_measured - comp_fast.I_comp
```

Set `C_fast` to match `PatchPipette.C_pipette` (they represent the same
physical capacitor — one models it, the other cancels it). On real hardware
this is the "fast" knob you tune first, watching the initial spike shrink
without leaving a residual under- or over-shoot.

> **A model subtlety worth knowing.** `CompensatedVClampAmp`'s command
> voltage is a mathematically *instantaneous* step (zero rise time). That
> makes $d(V_\text{cmd})/dt$ — and therefore `I_comp_fast` — exactly zero at
> every simulated time point except the single zero-width instant of the
> step itself, *unless* R_s compensation (`alpha > 0`) is active: alpha's
> feedback routes the command through the `tau_comp` low-pass filter, which
> is the only thing in this model that gives the command edge finite width
> for C-fast to actually act on. Concretely: with `alpha = 0`,
> `frac_fast` produces **no visible difference** between `I_raw` and
> `I_measured` in a plotted trace — confirmed by simulation, not a
> hypothetical edge case. `Step13` doesn't hit this because its default
> `alpha = 0.7` is already nonzero; `Step22_PipetteCapacitanceCompensation`
> (cell-attached, where R_s compensation isn't otherwise relevant) sets a
> small `alpha = 0.3` purely as a numerical device to make C-fast's effect
> observable — see that model's own documentation for the full derivation
> and verified numbers. On a real amplifier this isn't an issue, since a
> physical command output always has *some* finite (if very fast) slew rate
> regardless of R_s-compensation status.

---

## 4. C-slow: `WholeCellCapacitanceComp`

**Cancels artifact #2** (the slow exponential).

This one can't just differentiate the command voltage, because the real
transient is *filtered* by `R_s` on its way to `C_m`
(`I_Cm(t) = (V_step/R_s) * exp(-t/tau_s)`, `tau_s = R_s * C_m`). So the model
keeps its own internal RC estimator that reproduces that filtering:

$$\tau_s \frac{dV_{m,\text{est}}}{dt} = V_\text{cmd} - V_{m,\text{est}}, \qquad \tau_s = R_{s,\text{est}} \cdot C_\text{slow}$$

$$I_\text{comp,slow} = \text{fraction} \times C_\text{slow} \times \frac{dV_{m,\text{est}}}{dt}$$

`V_m_est` is a *model of a model* — an internal copy of the same RC charging
process the real membrane undergoes, built purely from parameters
(`R_s_est`, `C_slow`) rather than by measuring the cell directly. That's
exactly how real amplifiers do it too: you dial in your best estimate of the
cell's `C_m` (read off the seal-test/`SealTest` protocol) and `R_s_est`
(≈ `PatchPipette.R_pipette`), and the amplifier subtracts its internally
generated transient. Get the estimate wrong and you either under-compensate
(residual exponential remains) or over-compensate (a transient of the
*opposite* sign appears) — a good way to build intuition is to sweep
`R_s_est` away from the true `R_pipette` and watch `I_measured` for either
sign.

---

## 5. R_s compensation: `SeriesResistanceComp`

**Cancels artifact #3** (the voltage error) — arguably the most important
of the three, because it's not just a transient artifact, it distorts the
apparent *kinetics* of every ionic channel you're studying (a real membrane
potential lagging the command changes when the channels actually open).

The error is a simple Ohm's-law drop across `R_s`:

$$V_\text{error} = R_s \cdot I_\text{measured}$$

*Example:* `R_s = 10 MΩ`, peak Na⁺ current `I = -2 nA` → `V_error = 20 mV`.
For channels whose gating is voltage-sensitive over a 10-20 mV range, that's
enormous — it can make a channel look like it activates at the wrong
voltage or with the wrong time constant.

The fix is positive feedback: add a fraction `alpha` of the measured error
back onto the command, so the amplifier *overshoots* on purpose, by just
enough that after the `R_s` drop the cell actually receives `V_cmd`:

$$V_\text{cmd,corrected} = V_\text{cmd} + \alpha \cdot R_s \cdot I_\text{measured}$$

$$V_{m,\text{estimated}} = V_\text{cmd} - (1-\alpha) \cdot V_\text{error}$$

`alpha = 0.7` (70%) leaves only 30% of the error; `alpha = 0.8` leaves 20%.
**`alpha` is capped at 0.9 in this package** because it's positive feedback
around a real op-amp loop — push it too far (real amplifiers become
unstable around 90-95%) and instead of correcting the error you get
oscillation. That instability isn't just a hardware footnote — see §6.

---

## 6. Putting it together: `CompensatedVClampAmp`

This is a complete voltage-clamp amplifier with all three knobs built in
(`frac_fast`, `frac_slow`, `alpha`, all off/0 by default so it behaves
exactly like a plain `VoltageClampAmplifier` until you turn something on).
Signal flow:

```
V_command (V_hold/V_step, LJP-corrected)
      │
      ▼
  p.v - n.v = V_command + alpha * R_s * I_raw_filt   ──► drives the pipette
      ▲                                    (only when alpha > 0; positive
      │                                     feedback implementing R_s comp)
      │
  I_raw = -p.i    ─────────────► low-pass filter (tau_comp) ──► I_raw_filt
      │
      ├──► I_comp_fast = frac_fast * C_fast * d(V_cmd)/dt
      ├──► I_comp_slow = frac_slow * C_slow * d(V_m_est)/dt   (internal RC estimator, same as §4)
      │
      ▼
  I_measured = I_raw - I_comp_fast - I_comp_slow   ──► what you actually plot/analyze
```

Two implementation details are worth knowing about if you read the source,
because they're not just style choices — they were bugs the model had to be
built around:

- **Why the `alpha > 0` branch exists at all.** `alpha * R_s * I_raw` with
  `I_raw = -p.i` is a feedback loop through the amplifier's *own* current —
  the amplifier's output depends on a current that depends on the
  amplifier's output. At `alpha = 0` that loop term is mathematically zero,
  but the solver still sees a structurally singular system unless the term
  is removed entirely. Since `alpha` is a parameter (fixed before
  compilation, not a signal that changes during simulation), the
  `if alpha > 0 then ... else ...` is resolved *at compile time* — with the
  default `alpha = 0`, the feedback loop doesn't exist in the compiled
  model at all.
- **Why `I_raw_filt` (not `I_raw`) feeds the correction, via `tau_comp`.**
  Even with the loop present (`alpha > 0`), feeding back the *instantaneous*
  current is unstable: two capacitors sit in that loop (`C_pipette` and the
  cell's `C_m`), and ideal (zero-delay) positive feedback through two
  capacitive elements rings/blows up. Real amplifiers avoid this by
  band-limiting the R_s-compensation loop (a real, physical 5-20 µs time
  constant); `tau_comp` (default 15 µs) models exactly that:
  `tau_comp * der(I_raw_filt) = I_raw - I_raw_filt`. It only matters when
  `alpha > 0` — leave it at the default.

### Suggested exploration order (matches `Step13_SeriesResistanceCompensation`)

1. All compensations off (defaults) — look at `amp.I_raw`: you should see
   the fast spike + slow exponential + steady state from §2.
2. `frac_fast = 1.0` — the fast spike vanishes from `amp.I_measured`.
3. `frac_slow = 1.0` — the slow exponential vanishes too, leaving only the
   resistive/ionic current.
4. `alpha = 0.7` — watch `amp.V_error` shrink to 30% of its original value
   and `amp.V_m_estimated` converge toward the true command.

### Key parameters

| Parameter | Matches | Purpose |
|---|---|---|
| `C_fast` | `PatchPipette.C_pipette` | C-fast target capacitance |
| `frac_fast` | — | C-fast compensation fraction, 0-1 |
| `C_slow` | cell's `C_m` | C-slow target capacitance |
| `R_s_est` | `PatchPipette.R_pipette` | C-slow's internal `tau_s` estimate |
| `frac_slow` | — | C-slow compensation fraction, 0-1 |
| `R_s` | `PatchPipette.R_pipette` | R_s compensation target resistance |
| `alpha` | — | R_s compensation fraction, 0-0.9 (stability cap) |
| `tau_comp` | — | R_s feedback loop bandwidth, only matters if `alpha > 0` |

### Signals worth plotting

`I_raw`, `I_comp_fast`, `I_comp_slow`, `I_measured`, `V_error`,
`V_m_estimated` — see `CompensatedVClampAmp`'s own documentation for the
full list.

---

## 7. Using it in your own experiments

Swap `VoltageClampAmplifier` for `CompensatedVClampAmp` in any example that
uses one, set `C_fast`/`C_slow`/`R_s`/`R_s_est` to match the
`PatchPipette`/cell instance you're connected to, and turn the fractions/`alpha`
on one at a time as in §6's exploration order. If you only want to compensate
one specific artifact in isolation (e.g. for a teaching demo), you can also
instantiate `PipetteCapacitanceComp`, `WholeCellCapacitanceComp`, or
`SeriesResistanceComp` individually alongside a plain `VoltageClampAmplifier`
— they're signal-only blocks (`p.i = n.i = 0`), so they compute a correction
current/voltage from measured signals without carrying any of the pipette's
or cell's actual current.
