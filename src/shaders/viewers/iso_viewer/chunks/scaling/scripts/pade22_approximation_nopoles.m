clear, clc
syms a0 a1 a2 b1 b2 x x0 f00 f10 f20 f30 f40 fc
assume([a0 a1 a2 b1 x x0 f00 f10 f20 f30 fc], 'real')

N0_x = a0 + a1 * x + a2 * x^2;
D0_x = (b2*x + b1)^2 + 1; 
P0_x = N0_x / D0_x;

P1_x = simplify(diff(P0_x, x));
P2_x = simplify(diff(P1_x, x));
P3_x = simplify(diff(P2_x, x));
P4_x = simplify(diff(P3_x, x));

% Apply the restrictions
eq1 = subs(P0_x, x, x0) == f00;
eq2 = subs(P1_x, x, x0) == f10;
eq3 = subs(P2_x, x, x0) == f20;
eq4 = subs(P3_x, x, x0) == f30;
sol = solve([eq1, eq2, eq3, eq4], [a0 a1 a2 b1 b2]);

%% Simplify pade21
[num21, den21] = numden(pade21);
[quadratic_coeffs, x_terms] = coeffs(num21 - den21 * fc, x);
 quadratic_coeffs = simplify(quadratic_coeffs);

pretty(quadratic_coeffs)