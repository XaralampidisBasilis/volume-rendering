clc, clear

% Define symbolic variables
syms f000 f100 f010 f001 f110 f101 f011 f111 
syms d000 d100 d010 d001 d110 d101 d011 d111 
syms ox oy oz nx ny nz t 
syms x y z
assume([f000 f100 f010 f001 f110 f101 f011 f111 ...
        d000 d100 d010 d001 d110 d101 d011 d111 ...
        ox oy oz nx ny nz t ...
        x y z], 'real')

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
c = c000 + c100 + c010 + c001 + c011 + c101 + c110 + c111;

% Substitute variables
rx = ox + nx * t;
ry = oy + ny * t;
rz = oz + nz * t;
c = subs(c, [x, y, z], [rx, ry, rz]);

% Extract coefficients with respect to t
[c_coeffs, c_terms] = coeffs(c, [t, ox, oy, oz, nx, ny, nz]);
c_coeffs = simplify(c_coeffs);
f_coeffs = unique(c_coeffs);

disp([c_coeffs(:), c_terms(:)])

%% Simplification patterns

% Mapping
% f000 = d000;
% f001 = d001 + d000;
% f010 = d010 + d000;
% f100 = d100 + d000;
% f011 = d011 + d001 + d010 + d000;
% f101 = d101 + d001 + d100 + d000;
% f110 = d110 + d010 + d100 + d000;
% f111 = d111 + d011 + d101 + d110 + d100 + d010 + d001 + d000;

% Apply mapping 
a = simplify(subs(c, [f000 f001 f010 f100 f011 f101 f110 f111], [ ...
    d000, ...
    d001 + d000, ...
    d010 + d000, ...
    d100 + d000, ...
    d011 + d001 + d010 + d000, ...
    d101 + d001 + d100 + d000, ...
    d110 + d010 + d100 + d000, ...
    d111 + d011 + d101 + d110 + d100 + d010 + d001 + d000, ...
]));

[a_coeffs, a_terms] = coeffs(a, [t, nx, ny, nz, ox, oy, oz]);

disp([a_coeffs(:), a_terms(:)])

%% Efficient calculation of coefficients for glsl implementation

% Reverse Mapping
d000 = f000;
d001 = f001 - f000;
d010 = f010 - f000;
d100 = f100 - f000;
d011 = f000 - f001 - f010 + f011;
d101 = f000 - f001 - f100 + f101;
d110 = f000 - f010 - f100 + f110;
d111 = f001 - f000 + f010 - f011 + f100 - f101 - f110 + f111;

cubic_coeffs_1 = nx * ny * nz * d111;

cubic_coeffs_2 = nx * ny * (oz * d111 + d110) ...
               + ny * nz * (ox * d111 + d011) ...
               + nx * nz * (oy * d111 + d101);

cubic_coeffs_3 = nx * (oy * oz * d111 + oy * d110 + oz * d101 + d100) ...
               + ny * (ox * oz * d111 + ox * d110 + oz * d011 + d010) ...
               + nz * (ox * oy * d111 + ox * d101 + oy * d011 + d001);

cubic_coeffs_4 = ox * oy * oz * d111 ...
                    + ox * oy * d110 ...
                    + ox * oz * d101 ...
                    + oy * oz * d011 ...
                         + ox * d100 ...
                         + oy * d010 ...
                         + oz * d001 ...
                              + d000;

c_result = dot([cubic_coeffs_1, cubic_coeffs_2, cubic_coeffs_3, cubic_coeffs_4], [t^3, t^2, t^1, t^0]);

% Check condition to be zero
disp(simplify(c_result - c))

%% GLSL CODE

% // Compute vertex value differences to simplify computations
% float F[8];
% F[0] = f[0];
% F[1] = f[1] - f[0];
% F[2] = f[2] - f[0];
% F[3] = f[3] - f[0];
% F[4] = f[4] - f[3] - f[2] + f[0];
% F[5] = f[5] - f[3] - f[1] + f[0];
% F[6] = f[6] - f[2] - f[1] + f[0];
% F[7] = f[7] - f[6] - f[5] - f[4] + f[3] + f[2] + f[1] - f[0]; 

% // Compute grouping vectors for optimization
% vec4 F1 = vec4(F[1], F[2], F[3], F[7]);
% vec4 F2 = vec4(F[4], F[5], F[6], F[7]);
% vec4 O1 = vec4(ray_origin, 1.0);
% vec4 D1 = vec4(ray_direction, 1.0);
% vec4 O2 = O1.yxxw * O1.zzyw;
% vec4 D2 = D1.yxxw * D1.zzyw;

% // Compute cubic coeffs with grouped vector operations
% vec4 coeffs = vec4(

%     prod(O1) * F[7] + F[0]
%         + dot(F1.xyz, O1.xyz) 
%         + dot(F2.xyz, O2.xyz),

%     dot(D1.xyz, vec3(
%         dot(F1.wx, O2.xw) + dot(F2.zy, O1.yz), 
%         dot(F1.wy, O2.yw) + dot(F2.zx, O1.xz), 
%         dot(F1.wz, O2.zw) + dot(F2.yx, O1.xy))),

%     dot(D2.xyz, vec3(
%         dot(F2.wx, O1.xw), 
%         dot(F2.wy, O1.yw), 
%         dot(F2.wz, O1.zw))),

%     prod(D1) * F[7]
% );

% return coeffs;

%% Verify glsl code with homeomorphic matlab code
f = [f000 f100 f010 f001 f011 f101 f110 f111];
d = [d000 d100 d010 d001 d011 d101 d110 d111];

F = sym(zeros(1, 8));
F(1) = f(1);
F(2) = f(2) - f(1);
F(3) = f(3) - f(1);
F(4) = f(4) - f(1);
F(5) = f(5) - f(4) - f(3) + f(1);
F(6) = f(6) - f(4) - f(2) + f(1);
F(7) = f(7) - f(3) - f(2) + f(1);
F(8) = f(8) - f(7) - f(6) - f(5) + f(4) + f(3) + f(2) - f(1);

% Step 2: Compute grouping vectors for optimization
F1 = [F(2), F(3), F(4), F(8)]; % Group F1
F2 = [F(5), F(6), F(7), F(8)]; % Group F2
O1 = [ox, oy, oz, 1.0]; % Extend ray_origin with 1
D1 = [nx, ny, nz, 1.0]; % Extend ray_direction with 1
O2 = [O1(2)*O1(3), O1(1)*O1(3), O1(1)*O1(2), O1(4)];
D2 = [D1(2)*D1(3), D1(1)*D1(3), D1(1)*D1(2), D1(4)];

% Step 3: Compute cubic coefficients with grouped operations
cubic_coeffs = sym(zeros(1, 4));

cubic_coeffs(1) = prod(O1) * F(8) + F(1)  ... 
    + dot(F1(1:3), O1(1:3)) ...
    + dot(F2(1:3), O2(1:3));

cubic_coeffs(2) = dot(D1(1:3), [ ... 
    dot(F2([3,2]), O1([2,3])) + dot(F1([4,1]), O2([1,4])); ...
    dot(F2([3,1]), O1([1,3])) + dot(F1([4,2]), O2([2,4])); ...
    dot(F2([2,1]), O1([1,2])) + dot(F1([4,3]), O2([3,4])) ...
]);

cubic_coeffs(3) = dot(D2(1:3), [ ...
    dot(F2([4,1]), O1([1,4])); ...
    dot(F2([4,2]), O1([2,4])); ...
    dot(F2([4,3]), O1([3,4])) ...
]);

cubic_coeffs(4) = prod(D1) * F(8);

% Display coefficients
c_result = dot(cubic_coeffs, [t^0, t^1, t^2, t^3]);
disp(simplify(c_result - c))
