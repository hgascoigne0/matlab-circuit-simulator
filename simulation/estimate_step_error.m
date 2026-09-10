function [x_full, x_half, error_estimate] = ...
    estimate_step_error(circuit, state, dt, method)

    % One full timestep
    x_full = take_step(circuit, state, dt, method);

    % Two half timesteps
    dt_half = dt / 2;

    x_half_first = take_step(circuit, state, dt_half, method);

    % Update the state using the first half-step
    state_half = update_state(circuit, state, x_half_first, dt_half, method);

    x_half = take_step(circuit, state_half, dt_half, method);

    % Difference between the two approximations
    error_estimate = max(abs(x_half - x_full));

end