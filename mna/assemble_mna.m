function [A, b] = assemble_mna(circuit, state, dt, method)

    n = circuit.num_unknowns;

    A = zeros(n, n);
    b = zeros(n, 1);

    for k = 1:length(circuit.elements)
        
        element = circuit.elements(k);

        switch upper(element.type)

            case "R"
                n1 = get_node_index(circuit, element.n1);
                n2 = get_node_index(circuit, element.n2);
                [A_local, b_local] = resistor(element.value);
                indices = [n1, n2];

            case "C"
                n1 = get_node_index(circuit, element.n1);
                n2 = get_node_index(circuit, element.n2);
            
                % Get previous capacitor voltage and current
                [v_previous, i_previous] = ...
                    get_capacitor_history(state, element);
            
                % Get numerical-method coefficients
                [alpha, beta] = method( ...
                    dt, v_previous, i_previous / element.value);
            
                % Generate local capacitor stamp
                [A_local, b_local] = capacitor( ...
                    element.value, alpha, beta);
            
                indices = [n1, n2];

            case "V"

                branch_index = element.branch_index;

                n1 = get_node_index(circuit, element.n1);
                n2 = get_node_index(circuit, element.n2);

                [A_local, b_local] = voltage_source(element.value);

                indices = [n1, n2, branch_index];

            case "L"

                branch_index = element.branch_index;

                n1 = get_node_index(circuit, element.n1);
                n2 = get_node_index(circuit, element.n2);

                i_previous = state.element_history.(element.name).i;
                v_previous = state.element_history.(element.name).v;

                [alpha, beta] = method(dt, i_previous, v_previous / element.value);

                [A_local, b_local] = inductor(element.value, alpha, beta);

                indices = [n1, n2, branch_index];

            otherwise
                error("Unknown element type: %s", element.type);

        end

        % stamp local matrix into global matrix
        for i = 1:length(indices)

            if indices(i) == 0
                continue;
            end

            global_i = indices(i);

            b(global_i) = b(global_i) + b_local(i);

            for j = 1:length(indices)

                if indices(j) == 0
                    continue;
                end

                global_j = indices(j);

                A(global_i, global_j) = A(global_i, global_j) + A_local(i, j);
            end
        end
    end
end