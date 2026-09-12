function new_dt = compute_new_dt(old_dt, error_factor, method)

    damping_factor = 0.9;
    min_dt = 1e-12;
    max_dt = 1e-3;
    max_increase_factor = 2.0;

    % Get integration order
    switch func2str(method)

        case "backward_euler"
            order = 1;

        case "trapezoidal"
            order = 2;

        otherwise
            error("Timestep control not implemented for this method.");
    end

    % Avoid division by zero
    error_factor = max(error_factor, 1e-20);

    new_dt = damping_factor * old_dt * (1 / error_factor)^(1 / (order + 1));

    % Limit timestep growth
    new_dt = min(new_dt, max_increase_factor * old_dt);

    % Limit timestep
    new_dt = max(new_dt, min_dt);
    new_dt = min(new_dt, max_dt);

end