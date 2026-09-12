function [x_new, iterations] = take_step(circuit, state, dt, method)

    x_guess = state.x;

    max_iter = 50;
    tol = 1e-9;

    for k = 1:max_iter

        [A, b] = assemble_mna( ...
            circuit, state, dt, method, x_guess);

        x_new = A \ b;

        if max(abs(x_guess - x_new)) < tol
            iterations = k;
            return;
        end

        x_guess = x_new;
    end

    error("Newton did not converge.");

end