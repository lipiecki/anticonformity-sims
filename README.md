# Anticonformity simulations

A small Julia replication package for an agent-based model of opinion dynamics
in two factions. Agents hold one of three opinions (`-1`, `0`, or `1`) and update
their opinions in response to a sampled group's majority. The simulations compare
anticonformity, interactions across factions, and bounded confidence.

## Run the replication

Install [Juliaup](https://julialang.org/install/), the Julia version manager.

Run this command **from the package directory**

```sh
julia --project=. main.jl
```

The script installs the project dependencies with `Pkg.instantiate()` before
running, so the first run requires internet access. It takes no command-line
arguments; change the settings directly in `main.jl` to customize the experiment.

By default, each scenario runs 1,000 repetitions of 1,000 rounds, with two
factions of four agents and influence groups of three. It compares 0, 2, or 4
anticonformists per faction, with cross-faction interactions and bounded
confidence each switched off and on.

## Files and results

- `sim.jl`: the simulation function, returning opinion counts over time.
- `main.jl`: runs the scenarios, aggregates results, and creates plots.
- `figures/`: directory for generated figures.
- `outputs/`: mean opinion percentages (`trajectory_*.csv`) and their standard
  deviations (`noise_*.csv`) for all rounds. Rows represent rounds and
  columns represent the three opinion categories. The two extreme categories
  are reordered within each repetition so the first has the larger final count
  (ties put `+1` first); the middle column is neutral.
