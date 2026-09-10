function state = update_state(circuit, state, x_new, dt, method)

    for k = 1:length(circuit.elements)

        element = circuit.elements(k);

        if ~ismember(element.type, ["C", "L"])
            continue;
        end

        n1 = get_node_index(circuit, element.n1);
        n2 = get_node_index(circuit, element.n2);

        v_new = 0;

        if n1 ~= 0
            v_new = v_new + x_new(n1);
        end

        if n2 ~= 0
            v_new = v_new - x_new(n2);
        end

        % Previous state
        history = state.element_history.(element.name);

        v_previous = history.v;
        i_previous = history.i;

        switch upper(element.type)

            case "C"

                [alpha, beta] = method( ...
                    dt, v_previous, i_previous / element.value);

                i_new = element.value * (alpha * v_new + beta);

            case "L"

                % Inductor current is an MNA unknown
                i_new = x_new(element.branch_index);

        end

        % Store new history
        state.element_history.(element.name).v = v_new;
        state.element_history.(element.name).i = i_new;
    end
end