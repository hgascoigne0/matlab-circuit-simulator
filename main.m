clear;
clc;

addpath("parser");
addpath("mna");
addpath("simulation");
addpath("elements");
addpath("methods");

%% RC circuit

circuit = parse_netlist("circuits/rc.cir");

[time, solutions] = simulate( ...
    circuit, circuit.tstop, circuit.dt, @backward_euler, false);

R = 1e3;
C = 1e-6;
V0 = 1;
tau = R * C;

v_analytical = V0 * (1 - exp(-time / tau));
i_analytical = -(V0 / R) * exp(-time / tau);
i_analytical(1) = 0;

out = get_node_index(circuit, "out");
v_source_index = circuit.elements(1).branch_index;

[error_v, error_i] = validate_solution(circuit, solutions,v_analytical, ...
    i_analytical, out, v_source_index);

disp("RC Circuit");
fprintf("Maximum voltage error: %.6e V\n", error_v);
fprintf("Maximum current error: %.6e A\n", error_i);
fprintf("Number of accepted timesteps: %d\n\n", length(time) - 1);

v_sim = solutions(out, :);
i_sim = solutions(v_source_index, :);

figure;
subplot(2,1,1);
plot(time, v_sim, "b", time, v_analytical, "r--");
xlabel("Time (s)");
ylabel("Voltage (V)");
title("RC Circuit - Capacitor Voltage");
legend("Numerical", "Analytical");
grid on;

subplot(2,1,2);
plot(time, i_sim, "b", time, i_analytical, "r--");
xlabel("Time (s)");
ylabel("Current (A)");
title("RC Circuit - Source Current");
legend("Numerical", "Analytical");
grid on;

%% RL circuit

circuit = parse_netlist("circuits/rl.cir");

[time, solutions] = simulate( ...
    circuit, circuit.tstop, circuit.dt, @backward_euler, false);

R = 1e3;
L = 1e-3;
V0 = 1;
tau = L / R;

i_analytical = (V0 / R) * (1 - exp(-time / tau));
v_analytical = V0 * exp(-time / tau);
v_analytical(1) = 0;

out = get_node_index(circuit, "out");
inductor_index = circuit.elements(3).branch_index;

[error_v, error_i] = validate_solution(circuit, solutions, v_analytical, ...
    i_analytical, out, inductor_index);

disp("RL Circuit");
fprintf("Maximum voltage error: %.6e V\n", error_v);
fprintf("Maximum current error: %.6e A\n", error_i);
fprintf("Number of accepted timesteps: %d\n\n", length(time) - 1);

v_sim = solutions(out, :);
i_sim = solutions(inductor_index, :);

figure;
subplot(2,1,1);
plot(time, v_sim, "b", time, v_analytical, "r--");
xlabel("Time (s)");
ylabel("Voltage (V)");
title("RL Circuit - Inductor Voltage");
legend("Numerical", "Analytical");
grid on;

subplot(2,1,2);
plot(time, i_sim, "b", time, i_analytical, "r--");
xlabel("Time (s)");
ylabel("Current (A)");
title("RL Circuit - Inductor Current");
legend("Numerical", "Analytical");
grid on;

%% RLC circuit

circuit = parse_netlist("circuits/rlc.cir");

% Circuit parameters
R = 10;
L = 1e-3;
C = 1e-6;
V_source = 1;

alpha = R / (2 * L);
omega_0 = 1 / sqrt(L * C);
omega_d = sqrt(omega_0^2 - alpha^2);

% Analytical solution for validation
v_analytical = @(t) V_source * ( ...
    1 - exp(-alpha * t) .* ...
    (cos(omega_d * t) + ...
    (alpha / omega_d) * sin(omega_d * t)));

i_analytical = @(t) ...
    (V_source / (L * omega_d)) * ...
    exp(-alpha * t) .* sin(omega_d * t);

mid = get_node_index(circuit, "mid");
inductor_index = circuit.elements(3).branch_index;

%% Fixed timestep

[time_fixed, solutions_fixed] = simulate( ...
    circuit, circuit.tstop, circuit.dt, ...
    @backward_euler, false);

v_fixed = solutions_fixed(mid, :);
i_fixed = solutions_fixed(inductor_index, :);

[error_v_fixed, error_i_fixed] = validate_solution( ...
    circuit, solutions_fixed, ...
    v_analytical(time_fixed), ...
    i_analytical(time_fixed), ...
    mid, inductor_index);


%% Adaptive timestep

[time_adaptive, solutions_adaptive, dt_history] = simulate( ...
    circuit, circuit.tstop, circuit.dt, ...
    @backward_euler, true);

v_adaptive = solutions_adaptive(mid, :);
i_adaptive = solutions_adaptive(inductor_index, :);

[error_v_adaptive, error_i_adaptive] = validate_solution( ...
    circuit, solutions_adaptive, ...
    v_analytical(time_adaptive), ...
    i_analytical(time_adaptive), ...
    mid, inductor_index);

%% Results

disp("RLC Circuit");
fprintf("\nFixed timestep:\n");
fprintf("  Maximum voltage error: %.6e V\n", error_v_fixed);
fprintf("  Maximum current error: %.6e A\n", error_i_fixed);
fprintf("  Number of timesteps: %d\n", length(time_fixed) - 1);

fprintf("\nAdaptive timestep:\n");
fprintf("  Maximum voltage error: %.6e V\n", error_v_adaptive);
fprintf("  Maximum current error: %.6e A\n", error_i_adaptive);
fprintf("  Number of timesteps: %d\n\n", length(time_adaptive) - 1);


%% Plot voltage

figure;

plot(time_fixed, v_fixed, "b");
hold on;
plot(time_adaptive, v_adaptive, "g");
plot(time_fixed, v_analytical(time_fixed), "r--");

xlabel("Time (s)");
ylabel("Voltage (V)");
title("RLC Circuit - Capacitor Voltage");
legend( ...
    "Fixed numerical", ...
    "Adaptive numerical", ...
    "Analytical");
grid on;


%% Plot current

figure;

plot(time_fixed, i_fixed, "b");
hold on;
plot(time_adaptive, i_adaptive, "g");
plot(time_fixed, i_analytical(time_fixed), "r--");

xlabel("Time (s)");
ylabel("Current (A)");
title("RLC Circuit - Inductor Current");
legend( ...
    "Fixed numerical", ...
    "Adaptive numerical", ...
    "Analytical");
grid on;

%% Plot adaptive timestep

figure;

semilogy(time_adaptive(2:end), dt_history);

xlabel("Time (s)");
ylabel("Timestep (s)");
title("RLC Circuit - Adaptive Timestep");
grid on;

%% Convergence test

dt_values = [1e-7, 5e-8, 2.5e-8, 1.25e-8];
voltage_errors = zeros(size(dt_values));

for k = 1:length(dt_values)

    [time, solutions] = simulate( ...
        circuit, circuit.tstop, dt_values(k), ...
        @backward_euler, false);

    voltage_errors(k) = validate_solution( ...
        circuit, solutions, ...
        v_analytical(time), ...
        i_analytical(time), ...
        mid, inductor_index);

end

convergence_order = log(voltage_errors(2:end) ./ voltage_errors(1:end-1)) ...
    ./ log(dt_values(2:end) ./ dt_values(1:end-1));

disp("Estimated convergence order:");
disp(convergence_order);

figure;

loglog(dt_values, voltage_errors, "o-");

xlabel("Timestep (s)");
ylabel("Maximum voltage error (V)");
title("RLC Circuit - Backward Euler Convergence");
grid on;