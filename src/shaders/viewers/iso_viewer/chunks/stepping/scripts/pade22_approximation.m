clear, clc
syms a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc
assume([a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc], 'real')

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2 + f30 / factorial(3) * (x - x0)^3 + f40 / factorial(4) * (x - x0)^4;
pade22 = pade(taylor, x, 'Order', [2 2], 'ExpansionPoint', x0);

%% Simplify pade21
pade22 = simplify(subs(pade22, [x0, f40], [0, 0]));
[num, den] = numden(pade22);
[cubic_coeffs, x_terms] = coeffs(num - den * fc, x);
 cubic_coeffs = simplify(cubic_coeffs);

syms err
cubic_coeffs = subs(cubic_coeffs, fc, f00 - err);
cubic_coeffs = arrayfun(@(x) simplify(x), cubic_coeffs);

pretty(cubic_coeffs')
