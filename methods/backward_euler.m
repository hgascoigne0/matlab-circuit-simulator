function [alpha, beta] = backward_euler(dt, x_previous, dx_previous)

    alpha = 1 / dt;
    beta = -x_previous / dt;

end