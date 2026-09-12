# MATLAB Circuit Simulator

A MATLAB-based transient circuit simulator implementing Modified Nodal Analysis (MNA) and numerical time integration for RLC circuits.

The project was developed to explore the numerical methods used in transient circuit simulation, including implicit integration, adaptive timestep control, and numerical validation against analytical solutions.

## Features

* Modified Nodal Analysis (MNA)
* Backward Euler and trapezoidal time integration
* Adaptive timestep control using step-doubling error estimation
* Nonlinear device simulation using Newton–Raphson iteration
* Resistor, capacitor, inductor, voltage source and diode models
* SPICE-style netlist parsing
* Analytical validation and numerical convergence analysis

## Numerical methods

The simulator formulates the circuit equations using Modified Nodal Analysis. Dynamic elements are discretized using implicit time-integration schemes.

**Backward Euler** provides a first-order implicit method with good numerical stability for transient simulation.

**Trapezoidal integration** provides second-order accuracy and is useful for comparing the accuracy of different integration schemes.

For adaptive simulation, local error is estimated using step doubling: one full timestep is compared with two half timesteps. The timestep is reduced when the estimated error exceeds the specified tolerance and increased when the solution can be advanced safely with a larger step.

### Nonlinear Devices

The simulator supports nonlinear devices through Newton–Raphson iteration. A diode is currently implemented using the Shockley diode equation,

$$
I_D = I_S\left(e^{V_D/(nV_T)} - 1\right)
$$

At each Newton iteration, the diode is linearized around the current voltage estimate and represented as an equivalent conductance and current source in the MNA system. The process is repeated until the solution converges.

A diode transient test circuit is included in `circuits/diode.cir`.


### Validation

The simulator is validated using RC, RL, and RLC circuits with known analytical solutions. Numerical convergence is also evaluated by progressively reducing the timestep. For the RLC circuit, the measured convergence order for Backward Euler is approximately 1, consistent with its expected first-order accuracy.

Adaptive timestep control automatically adjusts the timestep according to the estimated local error while maintaining good agreement with the analytical solution.

A nonlinear RC-diode transient circuit is also included to validate Newton–Raphson iteration. The simulated capacitor voltage rises toward the diode's forward-voltage operating point, and the nonlinear solve converges within a small number of iterations per timestep.


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
