syms s t t0 t1 f0 f1 f2 f10 f11 f21 f31 stepping ray_spacing;

assume([s t t0 t1 f0 f1 f2 f10 f11 f21 f31 stepping ray_spacing], 'real')
assume(t0 <= t1)
assume(f0 <= f1)

% second order taylor approximation for t
T = f1 + f11 * (t - t1) + f21 / 2 * (t - t1)^2 + f31 / 6 * (t - t1)^3;

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
H = h00 * f0 + h01 * f1 + h10 * (t1 - t0) * f10 + h11 * (t1 - t0) * f11;
H = subs(H, s, (t - t0)/(t1 - t0));
H = simplify(H);

% hermite cubic polynomial derivatives in the interval [t0, t1]
H_prime = simplify(diff(H, t));
H_prime2 = simplify(diff(H_prime, t));
H_prime3 = simplify(diff(H_prime2, t));
H_prime4 = simplify(diff(H_prime3, t));

f21 = simplify(subs(H_prime2, t, t1));
f31 = simplify(subs(H_prime3, t, t1));
f41 = simplify(subs(H_prime4, t, t1));

pretty(f21)
pretty(f31)
pretty(f41)

