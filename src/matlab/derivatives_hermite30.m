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
syms dx slope g10 g11 
%slope = (f01 - f00) / (x1 - x0);
%g10 = f10 - slope;
%g11 = f11 - slope;

H11 = simplify(subs(H11, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
H21 = simplify(subs(H21, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
H31 = simplify(subs(H31, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
pretty([H11; H21; H31])
