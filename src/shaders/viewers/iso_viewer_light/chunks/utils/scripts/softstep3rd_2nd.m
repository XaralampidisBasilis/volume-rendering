clear, clc
syms x t g1 g2 s1 s2 p q a0 a1 a2 a3 b0 b1 
assume([x t g1 g2 s1 s2 p q a0 a1 a2 a3 b0 b1], 'real')

assume(0 < p & p < 1)
assume(0 < q & q < 1)
assume(1 < g1)
assume(0 < g2)
assume(0 < x & x < p)
assume(0 < t & t < 1)
assume(p/q < s1)
assume(0 < s2)

f0_x = (a3*x^3 + a2*x^2 + a1*x + a0) / (x^2 + b1*x + b0);

% First and second derivatives
f1_x = diff(f0_x, x);
f2_x = diff(f1_x, x);

% Apply the restrictions
eq1 = subs(f0_x, x, 0) == 0; % f(0) = 0
eq2 = subs(f0_x, x, p) == q; % f(p) = q
eq3 = subs(f1_x, x, 0) == 0; % f'(0) = 0
eq4 = subs(f1_x, x, p) == g1; % f'(p) = g
eq5 = subs(f2_x, x, p) == g2;% f''(p) = 0 

% Solve the system of equations
vars = [a0 a1 a2 a3];
sol = solve([eq1, eq2, eq3, eq4], vars, 'ReturnConditions', true);

f0_x = simplify(subs(f0_x, vars, [sol.(char(vars(1))), sol.(char(vars(2))), sol.(char(vars(3))), sol.(char(vars(4)))]));
f1_x = simplify(subs(f1_x, vars, [sol.(char(vars(1))), sol.(char(vars(2))), sol.(char(vars(3))), sol.(char(vars(4)))]));
f2_x = simplify(subs(f2_x, vars, [sol.(char(vars(1))), sol.(char(vars(2))), sol.(char(vars(3))), sol.(char(vars(4)))]));

f0_0 = simplify(subs(f0_x, x, 0));
f0_p = simplify(subs(f0_x, x, p));
f1_0 = simplify(subs(f1_x, x, 0));
f1_p = simplify(subs(f1_x, x, p));

pretty(f0_x)

%% Solve for f''(p) = g2

f2_p = simplify(subs(f2_x, x, p));

sol_b0 = simplify(solve(f2_p == g2, b0, 'ReturnConditions', false));
sol_b1 = simplify(solve(f2_p == g2, b1, 'ReturnConditions', false));

pretty(sol_b0)
pretty(sol_b1)

%% Solutions

g0_x = simplify(subs(f0_x, b0, sol_b0));
g1_x = simplify(diff(g0_x, x));
g2_x = simplify(diff(g1_x, x));

h0_x = simplify(subs(f0_x, b1, sol_b1));
h1_x = simplify(diff(h0_x , x));
h2_x = simplify(diff(h1_x , x));

pretty(g0_x)
pretty(h0_x)

%% Simplify

g0_t = simplify(subs(g0_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
g1_t = simplify(subs(g1_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
g2_t = simplify(subs(g2_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));

h0_t = simplify(subs(h0_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
h1_t = simplify(subs(h1_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));
h2_t = simplify(subs(h2_x, [x, g1, g2], [p * t, q/p * s1, q/p^2 * s2]));

pretty(g0_t)
pretty(h0_t)

b0_b1 = simplify(solve(g0_t == h0_t, b0));

%% Search Poles and Roots
[num_x, den_x] = numden(g0_x);
[res_x, quo_x] = polynomialReduce(num_x, den_x, x);

[res_param_x, res_term_x] = coeffs(res_x, x);
[quo_param_x, quo_term_x] = coeffs(quo_x, x);
[num_param_x, num_term_x] = coeffs(num_x, x);
[den_param_x, den_term_x] = coeffs(den_x, x);

zeros = solve(num_x == 0, x,'ReturnConditions', true);
poles = solve(den_x == 0, x,'ReturnConditions', true);
pretty(simplify(poles.x))

pole_mean = (poles.x(2) + poles.x(1))/ 2;
pole_radius = abs(poles.x(2) - poles.x(1))/ 2;
pole_discriminant = simplify((den_param_x(2)^2 - 4 * den_param_x(1)*den_param_x(3))/p^4);

%%
syms p1 p2 c1
assume([p1, p2 c1], 'real')

p1 = simplify(subs(poles.x(1), g, q/p*s));
p2 = simplify(subs(poles.x(2), g, q/p*s));

pretty(p1)
pretty(p2)

%c1 = 2 * p *(s-1)/(2*s-3);
p_min = -b1/2 - sqrt((b1/2)^2 + (b1/2) * c1);
p_max = -b1/2 + sqrt((b1/2)^2 + (b1/2) * c1);

pretty(p_min)
pretty(p_max)

assume((b1/2)^2 + (b1/2) * c1 > 0);
sol_min = solve(p_min < 0, b1, 'ReturnConditions', true);
sol_max = solve(p < p_max, 'ReturnConditions', true);

%% Limit

z_x = simplify(limit(s_x, b1, inf));
z1_x = diff(z_x, x);
z2_x = diff(z1_x, x);

z_t  = simplify(subs(z_x,  [x, g], [p * t, q/p * s]));
z1_t = simplify(subs(z1_x, [x, g], [p * t, q/p * s]));
z2_t = simplify(subs(z2_x, [x, g], [p * t, q/p * s]));

%% bounds

q1_max = simplify(limit(z1_x/x, x, 0));
q1_min = simplify(limit(subs(z1_x/x, [x p q], [1-x, 1-p, 1-q]), x, 1));

q2_max = simplify(limit(z2_x, x, p));
q2_min = simplify(limit(subs(z2_x/x, [x p q], [1-x, 1-p, 1-q]), x, p));


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
