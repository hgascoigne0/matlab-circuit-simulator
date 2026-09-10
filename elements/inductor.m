function [A_local, b_local] = inductor(L, alpha, beta)

    A_local = [
         0   0   1;
         0   0  -1;
         1  -1  -L * alpha
    ];
    
    b_local = [
        0;
        0;
        L * beta
    ];
    
end