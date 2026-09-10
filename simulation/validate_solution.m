function [error_v, error_i] = validate_solution( ...
    circuit, solutions, v_analytical, i_analytical, ...
    voltage_node, current_index)

    v_sim = solutions(voltage_node, :);
    i_sim = solutions(current_index, :);

    error_v = max(abs(v_sim - v_analytical));
    error_i = max(abs(i_sim - i_analytical));

end