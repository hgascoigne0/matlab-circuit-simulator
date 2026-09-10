function [A_local, b_local] = voltage_source(V)

    A_local = [
        0  0  1;
        0  0 -1;
        1 -1  0
    ];

    b_local = [0; 0; V];

end