syms s t t0 t1 f0 f1 g0 g1;

assume([s t t0 t1 f0 f1 g0 g1], 'real')
assume(t0 <= t1)

% hermite basis functions
h00 = 2*s^3 - 3*s^2 + 1;
h01 = -2*s^3 + 3*s^2;
h10 = s^3 - 2*s^2 + s;
h11 = s^3 - s^2;

% hermite cubic polynomial in the interval [t0, t1]
H = h00 * f0 + h01 * f1 + h10 * (t1 - t0) * g0 + h11 * (t1 - t0) * g1;
H = subs(H, s, (t - t0)/(t1 - t0));
H = simplify(H);

% hermite cubic polynomial derivative in the interval [t0, t1]
H_prime = diff(H, t);
H_prime = simplify(H_prime);

% hermite cubic polynomial double derivative in the interval [t0, t1]
H_prime2 = diff(H_prime, t);
H_prime2 = simplify(H_prime2);

% hermite cubic polynomial tripple derivative in the interval [t0, t1]
H_prime3 = diff(H_prime2, t);
H_prime3 = simplify(H_prime3);

% pretty(H);
% pretty(H_prime);
% pretty(H_prime2);

% compute polynomials at t = (t0 + t1)/2;
t_mid = (t0 + t1)/2;
H_mid = simplify(subs(H, t, t_mid));
H_prime_mid = simplify(subs(H_prime, t, t_mid));
H_prime2_mid = simplify(subs(H_prime2, t, t_mid));

% pretty(H_mid);
% pretty(H_prime_mid);
% pretty(H_prime2_mid);

% find taylor linear approximation to the point t = (t0 + t1)/2;
H_taylor1 = H_mid + H_prime_mid * (t - t_mid);
H_taylor2 = H_mid + H_prime_mid * (t - t_mid) + H_prime2_mid * (t - t_mid)^2;

H_taylor1 = simplify(H_taylor1);
H_taylor2 = simplify(H_taylor2);

pretty(H_taylor1);
pretty(H_taylor2);

%% simplify expressions
syms f_mid g_mid lambda delta;
%delta = t1 - t0; => t0 = t1 - delta;
%f_mid = (f0 + f1) / 2; => f0 = 2 * f_mid - f1;
%g_mid = (g0 + g1) / 2; = > g0 = 2 *g_mid - g1;
%lambda = (f1 - f0) / delta; => lambda = 2 * (f1 - f_mid) / delta; => f1 = lambda * delta / 2 + f_mid;

H_taylor1 = subs(H_taylor1, t0, t1 - delta);
H_taylor1 = subs(H_taylor1, f0, 2*f_mid - f1);
H_taylor1 = subs(H_taylor1, g0, 2*g_mid - g1);
H_taylor1 = subs(H_taylor1, f1, lambda * delta / 2 + f_mid);
H_taylor1 = simplify(H_taylor1);

H_taylor2 = subs(H_taylor2, t0, t1 - delta);
H_taylor2 = subs(H_taylor2, f0, 2*f_mid - f1);
H_taylor2 = subs(H_taylor2, g0, 2*g_mid - g1);
H_taylor2 = subs(H_taylor2, f1, lambda * delta / 2 + f_mid);
H_taylor2 = simplify(H_taylor2);

pretty(H_taylor1);
pretty(H_taylor2);


%% solve equation H_taylor = f2
syms f2;

t2_taylor1 = solve(H_taylor1 == f2, t);
spacing_taylor1 = simplify(t2_taylor1 - t1);
pretty(spacing_taylor1)

t2_taylor2 = solve(H_taylor2 == f2, t);
spacing_taylor2 = simplify(t2_taylor2 - t1);
pretty(spacing_taylor2)

