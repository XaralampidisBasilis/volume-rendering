clear, clc
syms a0 b1 b2 b3 x x0 x1 f00 f01 f10 f11 fc 
assume([a0 b1 b2 b3 x x0 x1 f00 f01 f10 f11 fc], 'real')

P0_x = (a0) / (1 + b1 * x + b2 * x^2 + b3 * x^3);
P1_x = diff(P0_x, x);

% Apply the restrictions
eq1 = subs(P0_x, x, x0) == f00;
eq2 = subs(P0_x, x, x1) == f01; 
eq3 = subs(P1_x, x, x0) == f10; 
eq4 = subs(P1_x, x, x1) == f11; 
sol = solve([eq1, eq2, eq3, eq4], [a0 b1 b2 b3]);

P0_x = simplify(subs(P0_x,  [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
pretty(P0_x)

%% compute derivatives
P1_x = simplify(diff(P0_x, x));
P2_x = simplify(diff(P1_x, x));
P3_x = simplify(diff(P2_x, x));

%% approximate higher order derivatives at x1
P11 = simplify(subs(P1_x, x, x1));
P21 = simplify(subs(P2_x, x, x1));
P31 = simplify(subs(P3_x, x, x1));

pretty([P11; P21; P31;])

%% simplify higher order derivatives at x1
syms dx slope 
%dx = x1 - x0;
%slope = (f01 - f00) / dx;

F21 = simplify(subs(P21, x1, dx + x0));
F21 = simplify(subs(F21, f01, f00 + slope * dx));
pretty(F21)

F31 = simplify(subs(P31, x1, dx + x0));
F31 = simplify(subs(F31, f01, f00 + slope * dx));
pretty(F31)

disp(simplify(subs(F21, [dx, slope], [x1 - x0, (f01 - f00) / (x1 - x0)]) - P21));
disp(simplify(subs(F31, [dx, slope], [x1 - x0, (f01 - f00) / (x1 - x0)]) - P31));
