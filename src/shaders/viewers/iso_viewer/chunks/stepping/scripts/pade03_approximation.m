clear, clc
syms a0 b1 b2 b3 x x0 f00 f10 f20 f30 fc
assume([a0 b1 b2 b3 x x0 f00 f10 f20 f30 fc], 'real')

padde = a0 / (1 + b1 * x + b2 * x^2 + b3 * x^3);

taylor = f00 + f10 / factorial(1) * x + f20 / factorial(2) * x^2 + f30 / factorial(3) * x^3;
pade03 = pade(taylor, x, 'Order', [0 3], 'ExpansionPoint', 0);

%% Simplify pade03
[num03, den03] = numden(pade03);
[quadratic_coeffs, x_terms] = coeffs(den03 * fc - num03, x);
 quadratic_coeffs = simplify(quadratic_coeffs);

pretty(quadratic_coeffs')
