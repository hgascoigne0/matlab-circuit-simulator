function x_new = take_step(circuit, state, dt, method)

    [A, b] = assemble_mna(circuit, state, dt, method);

    x_new = A \ b;

end