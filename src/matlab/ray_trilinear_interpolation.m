% Define symbolic variables
syms f000 f100 f010 f001 f110 f101 f011 f111 
syms d000 d100 d010 d001 d110 d101 d011 d111 
syms ox oy oz dx dy dz t 
syms x y z
assume([f000 f100 f010 f001 f110 f101 f011 f111 ...
        d000 d100 d010 d001 d110 d101 d011 d111 ...
        ox oy oz dx dy dz t ...
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
c = subs(c, [x, y, z], [ox + dx * t, oy + dy * t, oz + dz * t]);

% Extract coefficients with respect to t
[c_coeffs, c_terms] = coeffs(c, [t, dx, dy, dz, ox, oy, oz]);
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

[a_coeffs, a_terms] = coeffs(a, [t, dx, dy, dz, ox, oy, oz]);

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

cubic_coeffs_1 = dx * dy * dz * d111;

cubic_coeffs_2 = dx * dy * (oz * d111 + d110) ...
               + dy * dz * (ox * d111 + d011) ...
               + dx * dz * (oy * d111 + d101);

cubic_coeffs_3 = dx * (oy * oz * d111 + oy * d110 + oz * d101 + d100) ...
               + dy * (ox * oz * d111 + ox * d110 + oz * d011 + d010) ...
               + dz * (ox * oy * d111 + ox * d101 + oy * d011 + d001);

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

vec4 d1 = vec4(d100, d010, d001, d111);
vec4 d2 = vec4(d011, d101, d110, d111);
vec4 o = vec4(ox, oy, oz, 1.0);
vec4 d = vec4(dx, dy, dz, 1.0);
vec4 oo = vec4(ox * oy, oy * oz, ox * oz, 1.0);
vec4 dd = vec4(dy * dz, dx * dz, dx * dy, 1.0);

vec4 cubic_coeffs = vec4
(
    d.x * d.y * d.z * d1.w,
    dot(dd.xyz, vec3(dot(o.xw, d2.wx), dot(o.yw, d2.wy), dot(o.zw, d2.wz))),
    dot(d.xyz, vec3(dot(o.yz, d2.zy), dot(o.xz, d2.zx), dot(o.xy, d2.yx)) + vec3(dot(oo.xw, d1.wx), dot(oo.yw, d1.wy), dot(oo.zw, d1.wz))),
    o.x * o.y * o.z * d1.w + dot(o.xyz, d1.xyz) + dot(oo.xyz, d2.zyx) + d000
);


