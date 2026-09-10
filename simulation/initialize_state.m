function state = initialize_state(circuit)

    state.x = zeros(circuit.num_unknowns, 1);
    state.element_history = struct();

    for k = 1:length(circuit.elements)

        element = circuit.elements(k);

        if ~ismember(element.type, ["C", "L"])
            continue;
        end

        state.element_history.(element.name).v = 0;
        state.element_history.(element.name).i = 0;

        % Initial condition
        if ~isempty(element.initial_cond)

            switch upper(element.type)

                case "C"
                    state.element_history.(element.name).v = ...
                        element.initial_cond;

                case "L"
                    state.element_history.(element.name).i = ...
                        element.initial_cond;

            end
        end
    end
end