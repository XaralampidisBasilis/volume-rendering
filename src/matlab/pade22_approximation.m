clear, clc
syms a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc
assume([a0 b1 b2 b3 x x0 f00 f10 f20 f30 f40 fc], 'real')

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2 + f30 / factorial(3) * (x - x0)^3 + f40 / factorial(4) * (x - x0)^4;
pade22 = pade(taylor, x, 'Order', [2 2], 'ExpansionPoint', x0);

%% Explore poles

[N0_x, D0_x] = numden(pade22);
f40_x = simplify(solve(D0_x == 0, f40));
x_f40 = simplify(solve(D0_x == 0,  x));

D0_coeffs = coeffs(D0_x, x);
disrc_f40 = simplify(D0_coeffs(2)^2 - 4 * D0_coeffs(1) * D0_coeffs(3)) / 12;

assume(disrc_f40 >= 0)
f40_1 = simplify(solve(x_f40(1) == x0, f40));
f40_2 = simplify(solve(x_f40(2) == x0, f40));

assume(disrc_f40, "real")
f40_3 = simplify(solve(disrc_f40 == 0, f40));

%% Simplify pade21
pade22 = simplify(subs(pade22, [x0, f40], [0, 0]));
[num, den] = numden(pade22);
[poly_coeffs, x_terms] = coeffs(num - den * fc, x);
 cubic_coeffs = simplify(poly_coeffs);

syms err
poly_coeffs = subs(poly_coeffs, fc, f00 - err);
poly_coeffs = arrayfun(@(x) simplify(x), poly_coeffs);

pretty(poly_coeffs')

%% rerwite

mixed = [2 * f10 * f30 - 3 * f20^2, 3 * f10 * f20 - err * f30];
poly_coeffs_R = [ ...
    3 * f20 * mixed(1) + 2 * f30 * mixed(2), ...
    6 * (f10 * mixed(1) + err * f20 * f30), ...
    6 * err * mixed(1) ...
];


