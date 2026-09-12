function [A_local, b_local] = diode(V)

    % Assume a generic silicon diode
    Is = 1e-12;
    n = 1;
    Vt = 25.85e-3;

    % Diode current
    I = Is * (exp(V / (n * Vt)) - 1);

    % Diode conductance
    G = Is / (n * Vt) * exp(V / (n * Vt));

    % Equivalent current source
    I_eq = I - G * V;

    % MNA stamp
    A_local = [
         G  -G;
        -G   G
    ];

    b_local = [
        -I_eq;
         I_eq
    ];

end