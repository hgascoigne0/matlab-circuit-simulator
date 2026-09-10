function [A_local, b_local] = capacitor(C, alpha, beta)

    C_alpha = C * alpha;
    C_beta = C * beta;

    A_local = [
         C_alpha  -C_alpha;
        -C_alpha   C_alpha
    ];

    b_local = [
        -C_beta;
         C_beta
    ];

end