function [A_local, b_local] = resistor(R)

    G = 1 / R;

    A_local = [ G  -G;
               -G   G];
    b_local = [0; 0];
    
end