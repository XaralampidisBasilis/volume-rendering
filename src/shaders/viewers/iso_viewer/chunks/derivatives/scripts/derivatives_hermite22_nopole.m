clear, clc
syms a0 a1 a2 a3 b1 b2 b3 x x0 x1 f00 f01 f10 f11 f20 f21 f30 f31 fc 
assume([a0 a1 a2 a3 b1 b2 b3 x x0 x1 f00 f01 f10 f11 f20 f21 f30 f31 fc], 'real')

% Analytic form
N0_x = (x - x1).^2 .* (f00 + f10 .* (x - x0)) + ...
       (x - x0).^2 .* (f01 + f11 .* (x - x1));
D0_x = (x - x1).^2 + (x - x0).^2;
P0_x = N0_x / D0_x;

P1_x = simplify(diff(P0_x, x));
P2_x = simplify(diff(P1_x, x));
P3_x = simplify(diff(P2_x, x));
P4_x = simplify(diff(P3_x, x));

simplify(subs(P1_x, x, x0))

%% Results
syms dx slope g10 g11 

P01 = simplify(subs(P0_x, x, x1));
P11 = simplify(subs(P1_x, x, x1));
P21 = simplify(subs(P2_x, x, x1));
P31 = simplify(subs(P3_x, x, x1));

P01 = simplify(subs(P01, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P11 = simplify(subs(P11, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P21 = simplify(subs(P21, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P31 = simplify(subs(P31, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));

pretty([P01; P11; P21; P31])
