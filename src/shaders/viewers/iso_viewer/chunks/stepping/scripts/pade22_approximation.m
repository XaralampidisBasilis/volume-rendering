clear, clc
syms a0 a1 a2 b1 x x1 f01 f11 f21 f31 f41 fc
assume([ a0 a1 a2 b1 x x1 f01 f11 f21 f31 f41 fc], 'real')

padde = (a0 + a1 * x + a2 * x^2) / (1 + b1 * x);

taylor = f01 + f11 / factorial(1) * (x - x1) + f21 / factorial(2) * (x - x1)^2 + f31 / factorial(3) * (x - x1)^3 + f41 / factorial(4) * (x - x1)^4;
pade22 = pade(taylor, x, 'Order', [2 2], 'ExpansionPoint', x1);

%% Simplify pade21
pade22 = simplify(subs(pade22, [x1, f41], [0, 0]));
[num, den] = numden(pade22);
[cubic_coeffs, x_terms] = coeffs(num - den * fc, x);
 cubic_coeffs = simplify(cubic_coeffs);

syms err
cubic_coeffs = subs(cubic_coeffs, fc, f01 - err);
cubic_coeffs = arrayfun(@(x) simplify(x), cubic_coeffs);

pretty(cubic_coeffs')
