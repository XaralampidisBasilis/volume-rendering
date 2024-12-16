clc, clear

% Define symbolic variables
syms x y z
assume([x y z], 'real')
assume(0 <= x & x <= 1)
assume(0 <= y & y <= 1)
assume(0 <= z & z <= 1)

syms f000 f100 f010 f001 f011 f101 f110 f111 
assume([f000 f100 f010 f001 f011 f101 f110 f111], 'real')
assume(0 <= f000 & f000 <= 1)
assume(0 <= f100 & f100 <= 1)
assume(0 <= f010 & f010 <= 1)
assume(0 <= f001 & f001 <= 1)
assume(0 <= f001 & f001 <= 1)
assume(0 <= f110 & f110 <= 1)
assume(0 <= f101 & f101 <= 1)
assume(0 <= f011 & f011 <= 1)
assume(0 <= f111 & f111 <= 1)

syms h000 h100 h010 h001 h011 h101 h110 h111 
assume([h000 h100 h010 h001 h011 h101 h110 h111], 'real')
assume(0 <= h000 & h000 <= 1)
assume(0 <= h100 & h100 <= 1)
assume(0 <= h010 & h010 <= 1)
assume(0 <= h001 & h001 <= 1)
assume(0 <= h001 & h001 <= 1)
assume(0 <= h110 & h110 <= 1)
assume(0 <= h101 & h101 <= 1)
assume(0 <= h011 & h011 <= 1)
assume(0 <= h111 & h111 <= 1)

% Mapping
f000 = h000;
f001 = h001 + h000;
f010 = h010 + h000;
f100 = h100 + h000;
f011 = h011 + h001 + h010 + h000;
f101 = h101 + h001 + h100 + h000;
f110 = h110 + h010 + h100 + h000;
f111 = h111 + h011 + h101 + h110 + h100 + h010 + h001 + h000;

% Define the trilinear coefficients
c000 = (1 - x) * (1 - y) * (1 - z) * f000;
c100 = (0 + x) * (1 - y) * (1 - z) * f100;
c010 = (1 - x) * (0 + y) * (1 - z) * f010;
c001 = (1 - x) * (1 - y) * (0 + z) * f001;
c011 = (1 - x) * (0 + y) * (0 + z) * f011;
c101 = (0 + x) * (1 - y) * (0 + z) * f101;
c110 = (0 + x) * (0 + y) * (1 - z) * f110;
c111 = (0 + x) * (0 + y) * (0 + z) * f111;

% Combine all coefficients
c = simplify(c000 + c100 + c010 + c001 + c011 + c101 + c110 + c111);


% Extract coefficients with respect to t
[c_coeffs, c_terms] = coeffs(c, [x y z]);
c_coeffs = simplify(c_coeffs);

disp([c_coeffs(:), c_terms(:)])

% Reverse Mapping
% h000 = f000;
% h001 = f001 - f000;
% h010 = f010 - f000;
% h100 = f100 - f000;
% h011 = f000 - f001 - f010 + f011;
% h101 = f000 - f001 - f100 + f101;
% h110 = f000 - f010 - f100 + f110;
% h111 = f001 - f000 + f010 - f011 + f100 - f101 - f110 + f111;

%% Partial Derivatives
grad = [diff(c, x), diff(c, y), diff(c, z)];
critical = solve(grad == 0, [x, y, z]);
critical.x = simplify(critical.x);
critical.y = simplify(critical.y);
critical.z = simplify(critical.z);

extrema = [subs(c, [x, y, z], [critical.x(1), critical.y(1), critical.z(1)]), ...
           subs(c, [x, y, z], [critical.x(2), critical.y(2), critical.z(2)])];
extrema = simplify(extrema);

%% Solve
syms f
assume(f, 'real')
assume(0 <= f & f <= 1)
