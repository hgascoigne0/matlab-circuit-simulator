function [alpha, beta] = trapezoidal(dt, x_previous, dx_previous)

    alpha = 2 / dt;
    beta = -2 * x_previous / dt - dx_previous;

end