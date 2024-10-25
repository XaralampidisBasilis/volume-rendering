clear, clc
syms a0 a1 a2 b1 x x1 f01 f11 f21 f31 f41 fc
assume([ a0 a1 a2 b1 x x1 f01 f11 f21 f31 f41 fc], 'real')

padde = (a0 + a1 * x) / (1 + b1 * x);

taylor = f01 + f11 / factorial(1) * (x - x1) + f21 / factorial(2) * (x - x1)^2 + f31 / factorial(3) * (x - x1)^3 + f41 / factorial(4) * (x - x1)^4;
pade11 = pade(taylor, x, 'Order', [1 1], 'ExpansionPoint', x1);

%% Simplify pade02
[num11, den11] = numden(pade11);
[linear_coeffs, x_terms] = coeffs(num11 - fc * den11, x);
 linear_coeffs = simplify(linear_coeffs);

pretty(linear_coeffs')