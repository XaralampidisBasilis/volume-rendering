syms t t0 t1 t2 f0 f1 f2 s s0 s1 s2 a b;

assume([t0 t1 t2 f0 f1 f2 s s0 s1 s2 a b], 'real')


% Construct the right-hand side vector b (function values)
f = [f0; f1; f2];

% Define the matrix A symbolically
T = [1, t0, t0^2;
     1, t1, t1^2;
     1, t2, t2^2];
 
% solve for coefficients
 coeff_t = simplify(T \ f);
 
% factor coefficients 
[numer, denom] = numden(coeff_t);
numer = collect(simplify(numer), [f0, f1, f2]);
parenthesis = arrayfun(@(x) flip(coeffs(x, [f0, f1, f2])), numer, 'UniformOutput', false);
factored = cellfun(@(array) arrayfun(@(symbolic) prod(factor(symbolic)), array), parenthesis, 'UniformOutput', false);
coeff_t = cellfun(@(array) dot(array, [f0, f1, f2]), factored, 'UniformOutput', true) ./ denom;

% get lagrange polynomial
lagrange_t = simplify([1.0, t, t^2] * coeff_t);
pretty(lagrange_t)

% change of variable
lagrange_s = subs(lagrange_t, t, s * a + b);
lagrange_s = subs(lagrange_s, t0, s0 * a + b);
lagrange_s = subs(lagrange_s, t1, s1 * a + b);
lagrange_s = subs(lagrange_s, t2, s2 * a + b);
coeff_s = fliplr(coeffs(simplify(lagrange_s), s));
lagrange_s = poly2sym(coeff_s, s);

pretty(lagrange_s)
