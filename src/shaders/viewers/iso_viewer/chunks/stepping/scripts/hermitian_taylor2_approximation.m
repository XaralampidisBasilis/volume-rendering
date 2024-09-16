syms t t0 t1 f0 f1 g0 g1 a1 j1 stepping ray_spacing;

assume([t t0 t1 f0 f1 f2 g0 g1 a1 j1 stepping ray_spacing], 'real')
assume(t0 <= t1)
assume(f0 <= f1)

% second order taylor approximation for t
T = f1 + g1 * (t - t1) + a1 / 2 * (t - t1)^2 + j1 * (t - t1)^3;

% we want to solve for equation T(t)- f2 == 0 and stepping = (t - t1) / ray_spacing; =>  t = stepping * ray_spacing + t1;
S = simplify(subs(T - f2, t, stepping * ray_spacing + t1));
[S_coeffs, S_terms] = coeffs(S, stepping);
stepping_roots = solve(S == 0, stepping);

pretty(dot(S_coeffs, S_terms));
pretty(stepping_roots)

%% hermite approximation to compute derivatives at t1

% hermite basis functions
h00 = 2*s^3 - 3*s^2 + 1;
h01 = -2*s^3 + 3*s^2;
h10 = s^3 - 2*s^2 + s;
h11 = s^3 - s^2;

% hermite cubic polynomial in the interval [t0, t1]
H = h00 * f0 + h01 * f1 + h10 * (t1 - t0) * g0 + h11 * (t1 - t0) * g1;
H = subs(H, s, (t - t0)/(t1 - t0));
H = simplify(H);

% hermite cubic polynomial derivatives in the interval [t0, t1]
H_prime = simplify(diff(H, t));
H_prime2 = simplify(diff(H_prime, t));
H_prime3 = simplify(diff(H_prime3, t));

a1 = simplify(subs(H_prime2, t, t1));
j1 = simplify(subs(H_prime3, t, t1));

pretty(a1)
pretty(j1)


