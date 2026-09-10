function [v_previous, i_previous] = get_capacitor_history(state, element)

    history = state.element_history.(element.name);

    v_previous = history.v;
    i_previous = history.i;

end