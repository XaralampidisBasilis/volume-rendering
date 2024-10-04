clear, clc
syms a0 a1 b1 x x0 f00 f10 f20 fc
assume([a0 a1 b1 x x0 f00 f10 f20 fc], 'real')

padde = (a0 + a1 * x) / (1 + b1 * x);

taylor = f00 + f10 / factorial(1) * x + f20 / factorial(2) * x^2;
pade11 = pade(taylor, x, 'Order', [1 1], 'ExpansionPoint', 0);

%% Simplify pade02
[num11, den11] = numden(pade11);
[linear_coeffs, x_terms] = coeffs(num11 - den11 * fc, x);
 linear_coeffs = simplify(linear_coeffs);

pretty(linear_coeffs)