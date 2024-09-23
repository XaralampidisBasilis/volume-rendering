syms x t a b c d e p q g s
assume([x t a b c d e p q g s], 'real')

assume(0 < p & p < 1)
assume(0 < q & q < 1)
assume(0 < g)
assume(0 < x & x < p)
assume(0 < t & t < 1)
assume(0 < s)

f_x = (a*x^3 + b*x^2 + c*x + d) / (x + e);

% First and second derivatives
f1_x = diff(f_x, x);
f2_x = diff(f1_x, x);

% Apply the restrictions
eq1 = subs(f_x, x, 0) == 0; % f(0) = 0
eq2 = subs(f_x, x, p) == q; % f(p) = q
eq3 = subs(f1_x, x, 0) == 0; % f'(0) = 0
eq4 = subs(f1_x, x, p) == g; % f'(p) = g
eq5 = subs(f2_x, x, p) == 0;% f''(p) = 0 

% Solve the system of equations
sol = solve([eq1, eq2, eq3, eq4, eq5], [a, b, c, d, e], 'ReturnConditions', true);

% Display the solution
a_sol = sol.a;
b_sol = sol.b;
c_sol = sol.c;
d_sol = sol.d;
e_sol = sol.e;

s_x  = simplify(subs(f_x,  [a, b, c, d, e], [a_sol, b_sol, c_sol, d_sol, e_sol]));
s1_x = simplify(subs(f1_x, [a, b, c, d, e], [a_sol, b_sol, c_sol, d_sol, e_sol]));
s2_x = simplify(subs(f2_x, [a, b, c, d, e], [a_sol, b_sol, c_sol, d_sol, e_sol]));

pretty(s_x)

%% Simplify

s_t  = simplify(subs(s_x,  [x, g], [p * t, q/p * s]));
s1_t = simplify(subs(s1_x, [x, g], [p * t, q/p * s]));
s2_t = simplify(subs(s2_x, [x, g], [p * t, q/p * s]));

pretty(s_t)

%% Solution Simplified s_x
[num_t, den_t] = numden(s_t);
disp(factor(num_t))

pol_num_t = 2*s*t - t - 3*s - s^2*t + s^2 + 3;
pol_den_t = s + 3*t - 2*s*t - 1;

[num_param_t, num_term_t] = coeffs(pol_num_t, t);
[den_param_t, den_term_t] = coeffs(pol_den_t, t);

s_t = q * t^2 * dot(num_param_t, num_term_t) / dot(den_param_t, den_term_t);
pretty(s_t)

%% Solution Simplified s1_x

[num1_t, den1_t] = numden(s1_t);
disp(factor(num1_t))

pol_num1_t = 4*s^3*t^2 - 5*s^3*t + 2*s^3 - 14*s^2*t^2 + 18*s^2*t - 8*s^2 + 16*s*t^2 - 24*s*t + 12*s - 6*t^2 + 12*t - 6;
pol_den1_t = s + 3*t - 2*s*t - 1;

[num1_param_t, num1_term_t] = coeffs(pol_num1_t, t);
[den1_param_t, den1_term_t] = coeffs(pol_den1_t, t);

s1_t = (q/p * t) * dot(num1_param_t, num1_term_t) / dot(den1_param_t, den1_term_t)^2;
pretty(s1_t)

%% Find condition for q so that for every x z1_x >= 0

equation1 = solve(s1_x == 0, q);
q_max = simplify(limit(equation1, x, 0));

equation2 = solve(subs(s1_x, [x p q], [1-x, 1-p, 1-q]) == 0, q);
q_min = simplify(limit(equation2, x, 1));

pretty([q_min, q_max])
