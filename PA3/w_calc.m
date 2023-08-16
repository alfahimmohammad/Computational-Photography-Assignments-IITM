function [w] = w_calc(Z_vals)
Z_max = 255;
Z_min = 0;
Z_mid = 129;
w = zeros(size(Z_vals));
truth_array = Z_vals <= Z_mid;
w(truth_array) = Z_vals(truth_array) - Z_min;
w(~truth_array) = Z_max - Z_vals(~truth_array);
end