clear, clc
syms a0 a1 b1 b2 x x0 x1 f00 f01 f10 f11 fc 
assume([a0 a1 b1 b2 x x0 x1 f00 f01 f10 f11 fc ], 'real')

P0_x = (a0 + a1 * x) / (1 + b1 * x + b2 * x^2);
P1_x = diff(P0_x, x);

% Apply the restrictions
eq1 = subs(P0_x, x, x0) == f00;
eq2 = subs(P0_x, x, x1) == f01; 
eq3 = subs(P1_x, x, x0) == f10; 
eq4 = subs(P1_x, x, x1) == f11; 
sol = solve([eq1, eq2, eq3, eq4], [a0 a1 b1 b2]);

P0_x = simplify(subs(P0_x,  [a0 a1 b1 b2], [sol.a0, sol.a1, sol.b1, sol.b2]));
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
F21 = 2/dx * (f00 * (f11 - slope)^2 + dx * (slope^3 - f10 * f11^2)) / (slope * f00 - f10 * f01);
pretty(F21)

F31 = simplify(subs(P31, x1, dx + x0));
F31 = simplify(subs(F31, f01, f00 + slope * dx));

F31_0 = simplify(numden(F31) / 6);
F31_1 = simplify(F31_0 - f00^2 * (f11 - slope) * (f10 + f11 - 2*slope));
F31_2 = simplify(F31_1 - 3.0 * dx * f00 * slope^3 * (f10 + f11 - slope));

F31 = 6/dx^2  / (slope * f00 - f10 * f01)^2 * ( ...
        f00^2 * (f11 - slope) * (f10 + f11 - 2*slope) + ...
        3 * dx * f00 * (slope * f10 * ((f11 - slope)^2 + f11 * slope + (f11 - slope)*(slope^3 - f10 * f11^2))) + ...
        3 * dx^2 * f10 * (slope^4 - 2 * f11 * (slope^3 - f10 * f11^2)) ...
);
pretty(F31)

disp(simplify(subs(F21, [dx, slope], [x1 - x0, (f01 - f00) / (x1 - x0)]) - P21));
disp(simplify(subs(F31, [dx, slope], [x1 - x0, (f01 - f00) / (x1 - x0)]) - P31));
