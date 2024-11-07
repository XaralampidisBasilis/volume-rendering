syms x t g s p q a0 a1 a2 a3 b0 b1
assume([x t g s a0 a1 a2 a3 b0 b1], 'real')

assume(0 < p & p < 1)
assume(0 < q & q < 1)
assume(0 < g)
assume(0 < x & x < p)
assume(0 < t & t < 1)
assume(0 < s)

f_x = (a3*x^3 + a2*x^2 + a1*x + a0) / (x^2 + b1*x + b0);

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
sol = solve([eq1, eq2, eq3, eq4, eq5], [a0 a1 a2 a3 b0], 'ReturnConditions', true);

s_x  = simplify(subs(f_x,  [a0 a1 a2 a3 b0], [sol.a0, sol.a1, sol.a2, sol.a3, sol.b0]));
s1_x = simplify(subs(f1_x, [a0 a1 a2 a3 b0], [sol.a0, sol.a1, sol.a2, sol.a3, sol.b0]));
s2_x = simplify(subs(f2_x, [a0 a1 a2 a3 b0], [sol.a0, sol.a1, sol.a2, sol.a3, sol.b0]));

disp(s_x)
pretty(s_x)

%% Search Poles and Roots
[num_x, den_x] = numden(s_x);
[res_x, quo_x] = polynomialReduce(num_x, den_x, x);

[res_param_x, res_term_x] = coeffs(res_x, x);
[quo_param_x, quo_term_x] = coeffs(quo_x, x);
[num_param_x, num_term_x] = coeffs(num_x, x);
[den_param_x, den_term_x] = coeffs(den_x, x);

zeros = solve(num_x == 0, x,'ReturnConditions', true);
poles = solve(den_x == 0, x,'ReturnConditions', true);

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


%% Simplify

s_t  = simplify(subs(s_x,  [x, g], [p * t, q/p * s]));
s1_t = simplify(subs(s1_x, [x, g], [p * t, q/p * s]));
s2_t = simplify(subs(s2_x, [x, g], [p * t, q/p * s]));

pretty(s_t)

%% Limit



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
