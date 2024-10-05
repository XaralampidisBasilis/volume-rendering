clear, clc
syms a0 a1 a2 b1 x x0 x1 f00 f01 f10 f11 fc 
assume([a0 a1 a2 b1 x x0 x1 f00 f01 f10 f11 fc], 'real')

P0_x = (a0 + a1 * x + a2 * x^2) / (1 + b1 * x);
P1_x = diff(P0_x, x);

% Apply the restrictions
eq1 = subs(P0_x, x, x0) == f00;
eq2 = subs(P0_x, x, x1) == f01; 
eq3 = subs(P1_x, x, x0) == f10; 
eq4 = subs(P1_x, x, x1) == f11; 
sol = solve([eq1, eq2, eq3, eq4], [a0 a1 a2 b1]);

P0_x = simplify(subs(P0_x,  [a0 a1 a2 b1], [sol.a0, sol.a1, sol.a2, sol.b1]));
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
syms slope delta0 delta1 ratio10
%slope = (f01 - f00) / (x1 - x0);
%delta0 = f10 - slope;
%delta1 = f11 - slope;
%ratio10 = delta1 / delta0;

F21 = simplify(subs(P21, f01, f00 + slope * (x1 - x0)));
F31 = simplify(subs(P31, f01, f00 + slope * (x1 - x0)));

F21 = simplify(subs(F21, [f10, f11], [delta0 + slope, delta1 + slope]));
F31 = simplify(subs(F31, [f10, f11], [delta0 + slope, delta1 + slope]));

pretty([F21; F31])


