clear, clc
syms t x x0 x1 f00 f01 f10 f11;

assume([t x x0 x1 f00 f01 f10 f11], 'real')
assume (x0 <= x1)

% hermite basis functions
h00 = 2*t^3 - 3*t^2 + 1;
h01 = -2*t^3 + 3*t^2;
h10 = t^3 - 2*t^2 + t;
h11 = t^3 - t^2;

% hermite cubic polynomial in the interval  x0, x1]
H0_t = h00 * f00 + h01 * f01 + h10 * (x1 - x0) * f10 + h11 * (x1 - x0) * f11;
H0_x = simplify(subs(H0_t, t, (x - x0)/(x1 - x0)));

%% hermite cubic polynomial derivatives in the interval  [x0, x1]
H1_x = simplify(diff(H0_x, x));
H2_x = simplify(diff(H1_x, x));
H3_x = simplify(diff(H2_x, x));
H4_x = simplify(diff(H3_x, x));

%% approximate higher order derivatives at x1
H11 = simplify(subs(H1_x, x, x1));
H21 = simplify(subs(H2_x, x, x1));
H31 = simplify(subs(H3_x, x, x1));
H41 = simplify(subs(H4_x, x, x1));

pretty([H11; H21; H31; H41])

%% simplify higher order derivatives at x1
syms slope delta0 delta1 ratio10
%slope = (f01 - f00) / (x1 - x0);
%delta0 = f10 - slope;
%delta1 = f11 - slope;
%ratio10 = delta1 / delta0;

F21 = simplify(subs(H21, f01, f00 + slope * (x1 - x0)));
F31 = simplify(subs(H31, f01, f00 + slope * (x1 - x0)));

F21 = simplify(subs(F21, [f10, f11], [delta0 + slope, delta1 + slope]));
F31 = simplify(subs(F31, [f10, f11], [delta0 + slope, delta1 + slope]));
pretty([F21; F31])
