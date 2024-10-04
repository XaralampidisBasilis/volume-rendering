clear, clc
syms a0 a1 b1 x x0 f00 f10 f20 fc
assume([a0 a1 b1 x x0 f00 f10 f20 fc], 'real')

padde = (a0 + a1 * (x-x0)) / (1 + b1 * (x-x0));
[padde_num, padde_den] = numden(padde);

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2;

pade11 = pade(taylor, x, 'Order', [1 1], 'ExpansionPoint', x0);
pade02 = pade(taylor, x, 'Order', [0 2], 'ExpansionPoint', x0);

%% Equation
sol_x = simplify(solve(pade11 == fc, x));
spacing = simplify(sol_x - x0);


%% Simplify

[num11, den11] = numden(pade11);
[num11_coeffs, num11_terms] = coeffs(num11, x);
[den11_coeffs, den11_terms] = coeffs(den11, x);
num11_coeffs = simplify(num11_coeffs);
den11_coeffs = simplify(den11_coeffs);