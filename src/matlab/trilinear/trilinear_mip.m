clc, clear

% Define symbolic variables
syms f00 f10 f01 f11 
syms d00 d10 d01 d11 
syms ax ay vx vy t
syms x y
assume([f00 f10 f01 f11, ...
        d00 d10 d01 d11, ...
        ax ay vx vy t, ...
        x y], 'real')
    
% Mapping
% f00 = d00;
% f10 = d10 + d00;
% f01 = d01 + d00;
% f11 = d00 + d10 + d01 + d11;

% Reverse Mapping
% d00 = f00;
% d10 = f10 - f00;
% d01 = f01 - f00;
% d11 = f00 - f10 - f01 + f11;

% Define the trilinear coefficients
c00 = (1 - x) * (1 - y) * f00;
c10 = (0 + x) * (1 - y) * f10;
c01 = (1 - x) * (0 + y) * f01;
c11 = (0 + x) * (0 + y) * f11;

% Combine all coefficients
c = c00 + c10 + c01 + c11;

% Substitute variables of a line
rx = ax + vx * t;
ry = ay + vy * t;
c = simplify(subs(c, [x, y], [rx, ry]));

% Substitute change of variables to simplify
c = simplify(subs(c, [f00 f10 f01 f11], [ ...
    d00, ...
    d10 + d00, ...
    d01 + d00, ...
    d00 + d10 + d01 + d11, ...
]));

% Extract coefficients with respect to t
[c_coeffs, c_terms] = coeffs(c, t);
c_coeffs = simplify(c_coeffs);
disp([c_coeffs(:), c_terms(:)])

% Compute the derivative
d = simplify(diff(c, t));

% Extract coefficients with respect to t
[d_coeffs, d_terms] = coeffs(d, t);
d_coeffs = simplify(d_coeffs);
disp([d_coeffs(:), d_terms(:)])
