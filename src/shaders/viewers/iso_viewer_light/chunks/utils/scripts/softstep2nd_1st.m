clear, clc
syms x t g s p q a0 a1 a2 b0 b1 
assume([x t g s p q a0 a1 a2 b0 b1 ], 'real')

assume(0 < p & p < 1)
assume(0 < q & q < 1)
assume(1 < g)
assume(0 < x & x < p)
assume(0 < t & t < 1)
assume(0 < s)

f0_x = (a2*x^2 + a1*x + a0) / (b1*x + b0);

% First and second derivatives
f1_x = diff(f0_x, x);
f2_x = diff(f1_x, x);

% Apply the restrictions
eq1 = subs(f0_x, x, 0) == 0; % f(0) = 0
eq2 = subs(f0_x, x, p) == q; % f(p) = q
eq3 = subs(f1_x, x, 0) == 0; % f'(0) = 0
eq4 = subs(f1_x, x, p) == g; % f'(p) = g
%eq5 = subs(f2_x, x, p) == 0;% f''(p) = 0 

% Solve the system of equations
sol = solve([eq1, eq2, eq3, eq4], [a0 a1 a2 b0 b1], 'ReturnConditions', true);

% Display the solution
f0_x = simplify(subs(f0_x, [a0 a1 a2 b0 b1], [sol.a0, sol.a1, sol.a2, sol.b0, sol.b1]));
f1_x = simplify(subs(f1_x, [a0 a1 a2 b0 b1], [sol.a0, sol.a1, sol.a2, sol.b0, sol.b1]));
f2_x = simplify(subs(f2_x, [a0 a1 a2 b0 b1], [sol.a0, sol.a1, sol.a2, sol.b0, sol.b1]));

pretty(f0_x)

%% Simplify

f0_t = simplify(subs(f0_x, [x, g], [p * t, q/p * s]));
f1_t = simplify(subs(f1_x, [x, g], [p * t, q/p * s]));
f2_t = simplify(subs(f2_x, [x, g], [p * t, q/p * s]));

pretty(f0_t)

%% bounds

q1_max = simplify(limit(f1_x/x, x, 0)); % then solve for q for the equation q1_max > 0
q1_min = simplify(limit(subs(f1_x/x, [x p q], [1-x, 1-p, 1-q]), x, 1)); % then solve for q for the equation q1_min > 0

q2_max = simplify(limit(f2_x, x, p)); % then solve for q for the equation q2_max > 0
q2_min = simplify(limit(subs(f2_x/x, [x p q], [1-x, 1-p, 1-q]), x, p)); % then solve for q for the equation q2_max < 0

%% Inverse

h0_x = simplify(finverse(f0_x, x));
h0_x = simplify(subs(h0_x, [p, q], [q, p]));

% First and second derivatives
h1_x = diff(h0_x, x);
h2_x = diff(h1_x, x);

pretty(h0_x)

%% Simplify Inverse

h0_t = simplify(subs(h0_x, [x, g], [p * t, p/q * s]));
h1_t = simplify(subs(h1_x, [x, g], [p * t, p/q * s]));
h2_t = simplify(subs(h2_x, [x, g], [p * t, p/q * s]));

pretty(h0_t)

