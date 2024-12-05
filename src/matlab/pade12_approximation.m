clear, clc
syms a0 a1 b1 b2 x x0 f00 f10 f20 f30 fc
assume([ a0 a1 b1 b2 x x0 f00 f10 f20 f30 fc], 'real')

padde = (a0 + a1 * x) / (1 + b1 * x + b2 * x^2);

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2 + f30 / factorial(3) * (x - x0)^3;
pade12 = pade(taylor, x, 'Order', [1 2], 'ExpansionPoint', x0);

%% Simplify pade12
[num12, den12] = numden(pade12);
[quadratic_coeffs, x_terms] = coeffs(num12 - den12 * fc, x);
 quadratic_coeffs = simplify(quadratic_coeffs);

pretty(quadratic_coeffs')

%% Factoring
quadratic_coeffs_2 = 6* f10 * (f00 * f20 - 2*f10^2) + 2*(f00 - fc)*(3*f10*f20 - f00*f30);
disp(simplify(quadratic_coeffs(2) - quadratic_coeffs_2))