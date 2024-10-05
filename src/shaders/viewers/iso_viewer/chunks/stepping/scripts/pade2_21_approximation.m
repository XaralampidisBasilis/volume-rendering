clear, clc
syms a0 a1 a2 b1 x x0 x1 f00 f01 f10 f11 fc 
assume([a0 a1 a2 b1 x x0 x1 f00 f01 f10 f11 fc], 'real')

f_x = (a0 + a1 * x + a2 * x^2) / (1 + b1 * x);

% First and second derivatives
f1_x = diff(f_x, x);
f2_x = diff(f1_x, x);
f3_x = diff(f2_x, x);

% Apply the restrictions
eq1 = subs(f_x, x, x0) == f00;
eq2 = subs(f_x, x, x1) == f01; 
eq3 = subs(f1_x, x, x0) == f10; 
eq4 = subs(f1_x, x, x1) == f11; 

sol = solve([eq1, eq2, eq3, eq4], [a0 a1 a2 b1]);

f_x  = simplify(subs(f_x,  [a0 a1 a2 b1], [sol.a0, sol.a1, sol.a2, sol.b1]));
f1_x = simplify(subs(f1_x, [a0 a1 a2 b1], [sol.a0, sol.a1, sol.a2, sol.b1]));
f2_x = simplify(subs(f2_x, [a0 a1 a2 b1], [sol.a0, sol.a1, sol.a2, sol.b1]));
f3_x = simplify(subs(f3_x, [a0 a1 a2 b1], [sol.a0, sol.a1, sol.a2, sol.b1]));

f21 = simplify(subs(f2_x, x, x1));
f31 = simplify(subs(f3_x, x, x1));