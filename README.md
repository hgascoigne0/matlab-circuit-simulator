# MATLAB Circuit Simulator

A MATLAB-based transient circuit simulator implementing Modified Nodal Analysis (MNA) and numerical time integration for RLC circuits.

The project was developed to explore the numerical methods used in transient circuit simulation, including implicit integration, adaptive timestep control, and numerical validation against analytical solutions.

## Features

* Modified Nodal Analysis (MNA)
* Backward Euler and trapezoidal time integration
* Adaptive timestep control using step-doubling error estimation
* Resistor, capacitor, inductor, and voltage source models
* SPICE-style netlist parsing
* Analytical validation for RC, RL, and RLC circuits
* Convergence analysis of the numerical solution

## Numerical methods

The simulator formulates the circuit equations using Modified Nodal Analysis. Dynamic elements are discretized using implicit time-integration schemes.

**Backward Euler** provides a first-order implicit method with good numerical stability for transient simulation.

**Trapezoidal integration** provides second-order accuracy and is useful for comparing the accuracy of different integration schemes.

For adaptive simulation, local error is estimated using step doubling: one full timestep is compared with two half timesteps. The timestep is reduced when the estimated error exceeds the specified tolerance and increased when the solution can be advanced safely with a larger step.

## Validation

The simulator is validated against analytical solutions for standard transient circuits:

* **RC circuit** — capacitor charging
* **RL circuit** — inductor current rise
* **RLC circuit** — underdamped transient response

For each circuit, the numerical solution is compared with the corresponding analytical solution and the maximum voltage and current errors are calculated.

The RLC circuit is also used to compare fixed and adaptive timestep simulation. Adaptive stepping achieves comparable accuracy while requiring substantially fewer timesteps.

A convergence test using fixed-timestep Backward Euler shows the expected first-order convergence: halving the timestep approximately halves the numerical error, with the measured convergence order approaching 1.

## Project structure

```text
matlab-circuit-simulator/
├── main.m
├── circuits/       Example circuit netlists
├── elements/       Circuit element models and stamps
├── methods/        Numerical integration methods
├── mna/            MNA system assembly
├── parser/         Netlist parsing
└── simulation/     Time stepping, state management, and validation
```

Run the project from `main.m`. The script runs the example circuits, compares the numerical solutions with analytical solutions, and demonstrates adaptive timestep control and convergence.
