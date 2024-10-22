clear, clc

syms x t g1 g2 s1 s2 p q a0 a1 a2 a3 b0 b1
assume([x t g1 g2 s1 s2 p q a0 a1 a2 a3 b0 b1], 'real')

assume(0 < p & p < 1)
assume(0 < q & q < 1)
assume(1 < g1)
assume(0 < g2)
assume(0 < x & x < p)
assume(0 < t & t < 1)
assume(0 < s1)
assume(0 < s2)

f0_x = (a3*x^3 + a2*x^2 + a1*x + a0) / (x + b0);

% First and second derivatives
f1_x = diff(f0_x, x);
f2_x = diff(f1_x, x);

% Apply the restrictions
eq1 = subs(f0_x, x, 0) == 0; % f(0) = 0
eq2 = subs(f0_x, x, p) == q; % f(p) = q
eq3 = subs(f1_x, x, 0) == 0; % f'(0) = 0
eq4 = subs(f1_x, x, p) == g1; % f'(p) = g
eq5 = subs(f2_x, x, p) == g2;% f''(p) = g2 

% Solve the system of equations
sol = solve([eq1, eq2, eq3, eq4], [a0 a1 a2 a3], 'ReturnConditions', true);

% Display the solution
f0_x = simplify(subs(f0_x, [a0 a1 a2 a3], [sol.a0, sol.a1, sol.a2, sol.a3]));
f1_x = simplify(subs(f1_x, [a0 a1 a2 a3], [sol.a0, sol.a1, sol.a2, sol.a3]));
f2_x = simplify(subs(f2_x, [a0 a1 a2 a3], [sol.a0, sol.a1, sol.a2, sol.a3]));

pretty(f0_x)

%% Solve for second derivative variable

f2_p = simplify(subs(f2_x, x, p));
b0_p = simplify(solve(f2_p == g2, b0));

f0_x = simplify(subs(f0_x, b0, b0_p));
f1_x = simplify(subs(f1_x, b0, b0_p));
f2_x = simplify(subs(f2_x, b0, b0_p));

pretty(f0_x)

%% Simplify equations

f0_t = simplify(subs(f0_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
f1_t = simplify(subs(f1_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
f2_t = simplify(subs(f2_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));

pretty(f0_t)

%% Factor equations

[num0_t, den0_t] = numden(f0_t);
[num0_coeffs, num0_terms] = coeffs(num0_t, t);
[den0_coeffs, den0_terms] = coeffs(den0_t, t);
f0_t = dot(num0_coeffs, num0_terms) / dot(den0_coeffs, den0_terms);
pretty(f0_t)

%% bounds

q1_max = simplify(limit(s1_x/x, x, 0)); % then solve for q for the equation q1_max > 0
q1_min = simplify(limit(subs(s1_x/x, [x p q], [1-x, 1-p, 1-q]), x, 1)); % then solve for q for the equation q1_min > 0

pretty(q1_max)
pretty(q1_min)

q2_max = simplify(limit(s2_x, x, p)); % then solve for q for the equation q2_max > 0
q2_min = simplify(limit(subs(s2_x/x, [x p q], [1-x, 1-p, 1-q]), x, p)); % then solve for q for the equation q2_max < 0

pretty(q2_max)
pretty(q2_min)

