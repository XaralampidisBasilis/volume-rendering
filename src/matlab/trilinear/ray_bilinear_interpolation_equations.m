clc, clear

% Define symbolic variables
syms f00 f10 f01 f11 
assume([f00 f10 f01 f11], 'real');

syms d00 d10 d01 d11 
assume([d00 d10 d01 d11], 'real');

syms ax ay bx by t 
assume([ax ay bx by t], 'real');
syms x y
assume([x y], 'real');

% Define line segment
rx = ax + bx * t;
ry = ay + by * t;

% Define multiplicative factors
g00 = (1 - x) * (1 - y);
g10 = (0 + x) * (1 - y);
g01 = (1 - x) * (0 + y);
g11 = (0 + x) * (0 + y);

% Combine multiplicative factors to a vector
g = [g00; g10; g01; g11];
f = [f00; f10; f01; f11];
d = [d00; d10; d01; d11];

% Compute trilinear interpolant
c = dot(g, f);
c = subs(c, [x, y], [rx, ry]);
c = simplify(c);

% Extract coefficients with respect to t
[c_coeffs, t_terms] = coeffs(c, t);
c_coeffs = simplify(c_coeffs);
f_coeffs = unique(c_coeffs);
disp([c_coeffs(:), t_terms(:)]);

%% Mapping
% Define the 8x8 transformation matrix T, f = T * d
T = [
    1 0 0 0;  % f00 = d00
    1 1 0 0;  % f10 = d10 + d00
    1 0 1 0;  % f01 = d01 + d00
    1 1 1 1;  % f11 = d11 + d10 + d01 + d00
];

B = [
    1, -1, -1,  1;  
    1,  1, -1, -1;  
    1, -1,  1, -1;  
    1,  1,  1,  1;  
];

a = simplify(subs(c, f, inv(B) * d));
[a_coeffs, t_terms] = coeffs(a, t);
a_coeffs = simplify(a_coeffs);

disp([a_coeffs(:), t_terms(:)]);


%% Efficient calculation of coefficients for glsl implementation
% Define the inverse transformation matrix T_inv, d = T_inv * f
T_inv = [
    1,  0,  0,  0;   % d00 = f00
   -1,  1,  0,  0;   % d10 = f10 - f00
   -1,  0,  1,  0;   % d01 = f01 - f00
    1, -1, -1,  1;   % d11 = f00 - f10 - f01 + f11
];

B_inv = [
    1,  1,  1,  1;   % d00 = f11 + f10 + f01 + f00 
   -1,  1, -1,  1;   % d10 = f11 + f10 - f01 - f00
   -1, -1,  1,  1;   % d01 = f11 + f01 - f10 - f00
    1, -1, -1,  1;   % d11 = f11 - f10 - f01 + f00
] / 4;

% Define the transformation matrix M, coeffs = M * d
M = [
    0, 0,  0,  bx*by;
    0, bx, by, bx*ay + by*ax;
    1, ax, ay, ax*ay
];

aa_coeffs = sym(zeros(3,1));

aa_coeffs(1) = bx * by * d11;

aa_coeffs(2) = bx * (d10 + ay * d11) ...
             + by * (d01 + ax * d11);

aa_coeffs(3) = ax * ay * d11 ...
                  + ax * d10 ...
                  + ay * d01 ...
                       + d00;

aa = simplify(dot(M * d, [t^2, t^1, t^0]));
cc = simplify(subs(aa, d, T_inv * f));
disp(simplify(aa - a))
disp(simplify(cc - c))

%% Compute D4-symmetric average of M matrix

% Define corner permutations for each symmetry
permutations = {
    [1 2 3 4];  % identity
    [2 1 4 3];  % horizontal flip
    [3 4 1 2];  % vertical flip
    [4 3 2 1];  % 180 rotation
    [1 3 2 4];  % transpose
    [4 2 3 1];  % anti-diagonal
    [3 1 4 2];  % 90 ccw
    [2 4 1 3];  % 270 cw
};

% Define transformation functions for (x, y)
symmetries = {
    @(x, y) [x, y];                    % identity
    @(x, y) [1 - x, y];                % horizontal flip
    @(x, y) [x, 1 - y];                % vertical flip
    @(x, y) [1 - x, 1 - y];            % 180 rotation
    @(x, y) [y, x];                    % transpose
    @(x, y) [1 - y, 1 - x];            % anti-diagonal
    @(x, y) [y, 1 - x];                % 90 ccw
    @(x, y) [1 - y, x];                % 270 cw
};

Mavg = sym(zeros(3,4)); % accumulator

% Loop over all 8 symmetries
for i = 1:8

    % Transform the ray endpoints under symmetry
    a_new = symmetries{i}(ax, ay);
    c_new = symmetries{i}(ax + bx, ay + by);
    b_new = simplify(c_new - a_new);
    
    % Recompute the M matrix for this transformed ray
    M_i = [
        0,        0,        0, b_new(1) * b_new(2);
        0, b_new(1), b_new(2), b_new(1) * a_new(2) + b_new(2) * a_new(1);
        1, a_new(1), a_new(2), a_new(1) * a_new(2)
    ];

    % Apply the permutation matrix P_T to reorder d
    P = eye(4);
    P = P(permutations{i}, :);

    % Accumulate the transformed matrix
    Mavg = Mavg + M_i * P;
end

% Take the average over the 8 symmetries
Mavg = simplify(Mavg / 8);
disp('Symmetric average matrix Mavg:');
disp(Mavg);

%%
syms px py pz 
assume([px py pz], 'real');

syms ux uy uz 
assume([ux uy uz], 'real');

% px = ax + bx*t
% py = ay + by*t
% pz = az + bz*t

% This describes the following equation f(t) = c0t^0 + c1t^1 + c2t^2 + c3t^3 = dot(M(t), d)
Mt = simplify([t^2, t, 1] * Mavg);
Mt = simplify(subs(Mt, [ax, ay], [px - bx*t, py - by*t]));

% Since c3 = bx*by*bz * d111 we need to find bounds for d111
% We have f(t) = dot(M(t), d) =>
% px*py*pz * d111 = f(t) - dot(M0(t), d0), where M0, d0 are the rest
% We can substitute d0 = T0_inv * fw0
% So we have px*py*pz * d111 = f(t) - M0 * T0_inv = f(t) - W0 * f
M0 = Mt(1:end-1);
T0_inv = T_inv(1:end-1,:);
W0 = M0 * T0_inv;

disp(W0')
