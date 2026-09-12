function [time, solutions, dt_history] = simulate(circuit, t_end, dt, method, adaptive, tolerance)

    if nargin < 5
        adaptive = true;
    end

    if nargin < 6
        tolerance = 1e-6;
    end

    state = initialize_state(circuit);
    newton_iterations = [];

    time = 0;
    solutions = state.x;

    dt_history = [];

    t = 0;

    min_dt = 1e-12;

    while t < t_end

        dt_current = min(dt, t_end - t);


        % Use Backward Euler for the first timestep
        % when the main method is Trapezoidal.
        if t == 0 && isequal(func2str(method), "trapezoidal")
            current_method = @backward_euler;
        else
            current_method = method;
        end

        while true

            if adaptive

                % Estimate local error using step doubling
                [~, x_half, error_estimate] = ...
                    estimate_step_error(circuit, state, dt_current, current_method);
            
                % Reject timestep if error is too large
                if error_estimate > tolerance && dt_current > min_dt
                    dt_current = dt_current * 0.5;
                    continue;
                end
            
                % Accept the two-half-step solution
                x_new = x_half;
            
                error_factor = error_estimate / tolerance;
            
            else
            
                % Fixed timestep: take exactly one step
                [x_new, iterations] = take_step( ...
                    circuit, state, dt_current, current_method);

                newton_iterations(end+1) = iterations;
            
                error_factor = 0;
            
            end
            
            % Update element histories
            state_new = update_state(circuit, state, x_new, dt_current, current_method);
            
            state = state_new;
            
            break;

        end

        t = t + dt_current;

        time(end + 1) = t;
        solutions(:, end + 1) = x_new;
        dt_history(end + 1) = dt_current;

        if adaptive && error_factor > 0
            dt = compute_new_dt( ...
                dt_current, error_factor, current_method);
        else
            dt = dt_current;
        end

    end
end