clear, clc
syms a0 b1 b2 b3 x x0 x1 f00 f01 f10 f11 fc 
assume([a0 b1 b2 b3 x x0 x1 f00 f01 f10 f11 fc], 'real')

P0_x = (a0) / (1 + b1 * x + b2 * x^2 + b3 * x^3);
P1_x = simplify(diff(P0_x, x));
P2_x = simplify(diff(P1_x, x));
P3_x = simplify(diff(P2_x, x));

[N0_x, D0_x] = numden(P0_x);
N1_x = simplify(diff(N0_x, x));
N2_x = simplify(diff(N1_x, x));
N3_x = simplify(diff(N2_x, x));
D1_x = simplify(diff(D0_x, x));
D2_x = simplify(diff(D1_x, x));
D3_x = simplify(diff(D2_x, x));

% Apply the restrictions
eq1 = subs(P0_x, x, x0) == f00;
eq2 = subs(P0_x, x, x1) == f01; 
eq3 = subs(P1_x, x, x0) == f10; 
eq4 = subs(P1_x, x, x1) == f11; 
sol = solve([eq1, eq2, eq3, eq4], [a0 b1 b2 b3]);

%% compute derivatives
P0_x = simplify(subs(P0_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
P1_x = simplify(subs(P1_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
P2_x = simplify(subs(P2_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
P3_x = simplify(subs(P3_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
N0_x = simplify(subs(N0_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
N1_x = simplify(subs(N1_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
N2_x = simplify(subs(N2_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
N3_x = simplify(subs(N3_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
D0_x = simplify(subs(D0_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
D1_x = simplify(subs(D1_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
D2_x = simplify(subs(D2_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));
D3_x = simplify(subs(D3_x, [a0 b1 b2 b3], [sol.a0, sol.b1, sol.b2, sol.b3]));

%% approximate higher order derivatives at x1
P01 = simplify(subs(P0_x, x, x1));
P11 = simplify(subs(P1_x, x, x1));
P21 = simplify(subs(P2_x, x, x1));
P31 = simplify(subs(P3_x, x, x1));
N01 = simplify(subs(N0_x, x, x1));
N11 = simplify(subs(N1_x, x, x1));
N21 = simplify(subs(N2_x, x, x1));
N31 = simplify(subs(N3_x, x, x1));
D01 = simplify(subs(D0_x, x, x1));
D11 = simplify(subs(D1_x, x, x1));
D21 = simplify(subs(D2_x, x, x1));
D31 = simplify(subs(D3_x, x, x1));

%% simplify higher order derivatives at x1
syms dx slope g10 g11 f1
%dx = x1 - x0;
%slope = (f01 - f00) / dx;
%g10 = f10 - slope;
%g11 = f11 - slope;
%f1 = (f10 + f11) / 2;

P01 = simplify(subs(P01, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P11 = simplify(subs(P11, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P21 = simplify(subs(P21, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
P31 = simplify(subs(P31, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
N01 = simplify(subs(N01, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
N11 = simplify(subs(N11, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
N21 = simplify(subs(N21, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
N31 = simplify(subs(N31, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
D01 = simplify(subs(D01, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
D11 = simplify(subs(D11, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
D21 = simplify(subs(D21, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));
D31 = simplify(subs(D31, [x0, f00, f10, f11], [x1 - dx, f01 - slope * dx, g10 + slope, g11 + slope]));

%% Recursive formulas
syms x 
syms p0(x) p1(x) p2(x) p3(x)
syms n0(x) n1(x) n2(x) n3(x)
syms d0(x) d1(x) d2(x) d3(x)

P = [p0; p1; p2; p3];
N = [n0; n1; n2; n3];
D = [d0,    0,    0,  0;
     d1,   d0,    0,  0;
     d2, 2*d1,   d0,  0;
     d3, 3*d2, 3*d1, d0];

D0 = diag(diag(D));
LD = D - D0;
ND = D0\N;
LDD = D0\LD;
Y = ND - LDD * P; % recursive formula X == Y

%% Use recursive formula for derivative computation

N01_D01 = simplify(N01/D01);
N11_D01 = simplify(N11/D01);
N21_D01 = simplify(N21/D01);
N31_D01 = simplify(N31/D01);
D11_D01 = simplify(D11/D01);
D21_D01 = simplify(D21/D01);
D31_D01 = simplify(D31/D01);

% recursion formulas
P21_R = simplify(N21_D01 - 2 * D11_D01 * P11 - D21_D01 * P01);
P31_R = simplify(N31_D01 - 3 * D11_D01 * P21_R - 3 * D21_D01 * P11 - D31_D01 * P01 );

disp(simplify(subs(simplify(P21 - P21_R), [dx, slope, g10, g11], [x1 - x0, (f01 - f00) / (x1 - x0), f10 - (f01 - f00) / (x1 - x0), f11 - (f01 - f00) / (x1 - x0)])));
disp(simplify(subs(simplify(P31 - P31_R), [dx, slope, g10, g11], [x1 - x0, (f01 - f00) / (x1 - x0), f10 - (f01 - f00) / (x1 - x0), f11 - (f01 - f00) / (x1 - x0)])));

% rerwite
D11_D01_R = +1 / (f01 * f10 - f00 * slope) * (f00 / dx * (g10 + g11) - f10 * g11);
D21_D01_R = -2 / dx / (f01 * f10 - f00 * slope) * (slope * (g10 + g11) + g10 * g11) ;

disp(simplify(subs(simplify(D11_D01 - D11_D01_R), [dx, slope, g10, g11], [x1 - x0, (f01 - f00) / (x1 - x0), f10 - (f01 - f00) / (x1 - x0), f11 - (f01 - f00) / (x1 - x0)])));
disp(simplify(subs(simplify(D21_D01 - D21_D01_R), [dx, slope, g10, g11], [x1 - x0, (f01 - f00) / (x1 - x0), f10 - (f01 - f00) / (x1 - x0), f11 - (f01 - f00) / (x1 - x0)])));


