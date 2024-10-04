clear, clc
syms a0 a1 a2 b1 x x0 f00 f10 f20 f30 fc
assume([a0 a1 a2 b1 x x0 f00 f10 f20 f30 fc], 'real')

padde = (a0 + a1 * x + a2 * x^2) / (1 + b1 * x);

taylor = f00 + f10 / factorial(1) * x + f20 / factorial(2) * x^2 + f30 / factorial(3) * x^3;
pade21 = pade(taylor, x, 'Order', [2 1], 'ExpansionPoint', 0);

%% Simplify pade21
[num21, den21] = numden(pade21);
[quadratic_coeffs, x_terms] = coeffs(num21 - den21 * fc, x);
 quadratic_coeffs = simplify(quadratic_coeffs);

pretty(quadratic_coeffs)