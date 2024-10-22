syms x t a b c d p q g s
assume([x t a b c d e p q g s], 'real')

f_x = a*x^3 + b*x^2 + c*x + d;

% First and second derivatives
f1_x = diff(f_x, x);
f2_x = diff(f1_x, x);

% Apply the restrictions
% we need to remove one to be solvable
eq1 = subs(f_x, x, 0) == 0; % f(0) = 0
eq2 = subs(f_x, x, p) == q; % f(p) = q
eq3 = subs(f1_x, x, 0) == 0; % f'(0) = 0
eq4 = subs(f1_x, x, p) == g; % f'(p) = g
eq5 = subs(f2_x, x, p) == 0;% f''(p) = 0 

% Solve the system of equations
sol = solve([eq1, eq2, eq3, eq4], [a, b, c, d], 'ReturnConditions', true);

% Display the solution
a_sol = sol.a;
b_sol = sol.b;
c_sol = sol.c;
d_sol = sol.d;

s_x  = simplify(subs(f_x,  [a, b, c, d], [a_sol, b_sol, c_sol, d_sol]));
s1_x = simplify(subs(f1_x, [a, b, c, d], [a_sol, b_sol, c_sol, d_sol]));
s2_x = simplify(subs(f2_x, [a, b, c, d], [a_sol, b_sol, c_sol, d_sol]));

pretty(s_x)

%% Limit

s_t  = simplify(subs(s_x,  [x, g], [p * t, q/p * s]));
s1_t = simplify(subs(s1_x, [x, g], [p * t, q/p * s]));
s2_t = simplify(subs(s2_x, [x, g], [p * t, q/p * s]));

pretty(s_x)
pretty(s_t)

%% Solution Simplified

factors_t = factor(s_t);
%disp(factors_t)
pol_t = s*t - 2*t - s + 3;
[params_t, terms_t] = coeffs(pol_t, t);
s_t = q * t^2 * dot(params_t, terms_t);
pretty(s_t)

factors1_t = factor(s1_t);
%disp(factors1_t)
pol1_t = 3*s*t - 6*t - 2*s + 6;
[params1_t, terms1_t] = coeffs(pol1_t, t);
s1_t = (q/p * t) * dot(params1_t, terms1_t);
pretty(s1_t)

%% Find condition for q so that for every x z1_x >= 0

equation1 = solve(s1_x == 0, q);
q_min = simplify(limit(equation1, x, 0));

equation2 = solve(subs(s1_x, [x p q], [1-x, 1-p, 1-q]) == 0, q);
q_max = simplify(limit(equation2, x, 1));

pretty([q_min, q_max])
