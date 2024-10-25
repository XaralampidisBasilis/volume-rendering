clear, clc
syms a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc
assume([a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc], 'real')

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2 + f30 / factorial(3) * (x - x0)^3;
pade33 = pade(taylor, x, 'Order', [3 3], 'ExpansionPoint', x0);

%% Simplify pade21
pade33 = simplify(subs(pade33, x1, 0));
[num, den] = numden(pade33);
[polyn_coeffs, x_terms] = coeffs(num - den * fc, x);
 polyn_coeffs = simplify(polyn_coeffs);

syms err
polyn_coeffs = subs(polyn_coeffs, fc, f01 - err);
polyn_coeffs = arrayfun(@(x) simplify(x), polyn_coeffs);

pretty(polyn_coeffs')
