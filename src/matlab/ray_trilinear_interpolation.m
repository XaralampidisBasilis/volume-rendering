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
c110 = (0 + x) * (0 + y) * (1 - z) * f110;
c101 = (0 + x) * (1 - y) * (0 + z) * f101;
c011 = (1 - x) * (0 + y) * (0 + z) * f011;
c111 = (0 + x) * (0 + y) * (0 + z) * f111;

% Combine all coefficients
c = c000 + c100 + c010 + c001 + c110 + c101 + c011 + c111;

% Substitute variables
c = subs(c, [x, y, z], [ox + nx * t, oy + ny * t, oz + nz * t]);

% Extract coefficients with respect to t
[c_coeffs, c_terms] = coeffs(c, [t, nx, ny, nz, ox, oy, oz]);
c_coeffs = simplify(c_coeffs);
f_coeffs = unique(c_coeffs);

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

%% Glsl specific implementation

% Reverse Mapping
d000 = f000;
d001 = f001 - f000;
d010 = f010 - f000;
d100 = f100 - f000;
d011 = f000 - f001 - f010 + f011;
d101 = f000 - f001 - f100 + f101;
d110 = f000 - f010 - f100 + f110;
d111 = f001 - f000 + f010 - f011 + f100 - f101 - f110 + f111;

% GLSL CODE
% vec4 d1 = vec4(d100, d010, d001, d111);
% vec4 d2 = vec4(d011, d101, d110, d111);
% vec4 o = vec4(ox, oy, oz, 1.0);
% vec4 n = vec4(nx, ny, nz, 1.0);
% vec4 oo = o.yzxw * o.zxyw // vec4(oy * oz, ox * oz, ox * oy, 1.0);
% vec4 nn = n.yzxw * n.zxyw // vec4(ny * nz, nx * nz, nx * ny, 1.0);


% vec4 cubic_coeffs = vec4
% (
%     d111 * prod(n),
%     dot(nn.xyz, vec3(
%         dot(d2.wx, o.xw), 
%         dot(d2.wy, o.yw), 
%         dot(d2.wz, o.zw))),
%     dot(n.xyz, vec3(
%         dot(d2.zy, o.yz) + dot(d1.wx, oo.xw), 
%         dot(d2.zx, o.xz) + dot(d1.wy, oo.yw), 
%         dot(d2.yx, o.xy) + dot(d1.wz, oo.zw))),
%     d111 * prod(o) + d000
%       + dot(d1.xyz,  o.xyz) 
%       + dot(d2.xyz, oo.xyz) 
% );

% TRANSLATED MATLAB CODE
d1 = [d100, d010, d001, d111]; 
d2 = [d011, d101, d110, d111]; 
o = [ox, oy, oz, 1.0];         
n = [nx, ny, nz, 1.0];         

% Compute mixed terms
oo = o([2, 3, 1, 4]) .* o([3, 1, 2, 4]); % Equivalent to o.yzxw * o.zxyw
nn = n([2, 3, 1, 4]) .* n([3, 1, 2, 4]); % Equivalent to n.yzxw * n.zxyw

% Compute cubic coefficients
cubic_coeffs = [
    d111 * prod(n(1:3)), ...

    dot(nn(1:3), [dot(d2([4,1]), o([1,4])), ...
                  dot(d2([4,2]), o([2,4])), ...
                  dot(d2([4,3]), o([3,4]))]), ...

    dot(n(1:3), [dot(d2([3,2]), o([2,3])) + dot(d1([4,1]), oo([1,4])), ...
                 dot(d2([3,1]), o([1,3])) + dot(d1([4,2]), oo([2,4])), ...
                 dot(d2([2,1]), o([1,2])) + dot(d1([4,3]), oo([3,4]))]), ...

    d111 * prod(o(1:3)) + d000 + dot(d1(1:3), o(1:3)) + dot(d2(1:3), oo(1:3)) 
];

c_result = dot(cubic_coeffs, [t^3, t^2, t^1, t^0]);

disp(simplify(c_result - c))
