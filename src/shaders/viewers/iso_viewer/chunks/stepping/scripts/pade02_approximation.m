clear, clc
syms a0 b1 b2 x x0 f00 f10 f20 fc
assume([a0 b1 b2 x x0 f00 f10 f20 fc], 'real')

padde = a0 / (1 + b1 * x + b2 * x^2);

taylor = f00 + f10 / factorial(1) * x + f20 / factorial(2) * x^2;
pade02 = pade(taylor, x, 'Order', [0 2], 'ExpansionPoint', 0);

%% Simplify pade02
[num02, den02] = numden(pade02);
[quadratic_coeffs, x_terms] = coeffs(num02 - den02 * fc, x);
 quadratic_coeffs = simplify(quadratic_coeffs);

pretty(quadratic_coeffs)