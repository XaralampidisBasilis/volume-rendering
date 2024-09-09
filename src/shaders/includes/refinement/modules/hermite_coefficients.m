syms t0 t1 f0 f1 g0 g1;

assume([t0 t1 f0 f1 g0 g1], 'real')

% Define symbolic vectors for t, f, and f_prime
t = [t0; t1];
f = [f0; f1];
g = [g0; g1];

% Construct the right-hand side vector b (function values and derivatives)
b = [f(:); g(:)];

% Define the matrix A symbolically
A = [1, t0, t0^2,   t0^3;
     1, t1, t1^2,   t1^3;
     0,  1, 2*t0, 3*t0^2;
     0,  1, 2*t1, 3*t1^2];
    
% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2 + coeff[4] * t^3
polynomial_coeff_1 = simplify(A \ b);

[numerator_1, denominator_1] = numden(polynomial_coeff_1);
numerator_1 = collect(simplify(numerator_1), [f0, f1, g0, g1]);
parenthesis = arrayfun(@(x) flip(coeffs(x, [f0, f1, g0, g1])),numerator_1, 'UniformOutput', false);
factored = cellfun(@(array) arrayfun(@(symbolic) prod(factor(symbolic)), array), parenthesis, 'UniformOutput', false);
polynomial_coeff_3 = cellfun(@(array) dot(expand(array), [f0, f1, g0, g1]), factored, 'UniformOutput', true) ./ denominator_1;

% Compute dt and its cube, ensuring stability
dt = t0 - t1;
dt2 = dt^2;
dt3 = dt^3;
fg = [f' ./ dt3, g' ./ dt2];
t1010 = [t1, t0, t1, t0];
t0101 = [t0, t1, t0, t1];
u0 = [-1.0, 1.0, 0.0, 0.0];
u1 = [0.0, 0.0, 1.0, 1.0];
u2 = u0 .* 3.0 + u1;

% Coefficients as symbolic dot products
coeff1 = dot(t1010 .* u0 - t0101 .* u2, fg .* t1010 .* t1010);
coeff2 = dot(t1010 .* u1 + t0101 .* u2 .* 2.0, fg .* t1010);
coeff3 = dot(t1010 .* (u2 + u1) + t0101 .* u2, -fg);
coeff4 = dot(u0 .* 2.0 + u1, fg);

% Output all coefficients as a vector
polynomial_coeff_2 = simplify(expand([coeff1; coeff2; coeff3; coeff4]));

% Display the difference
coeff_diff = simplify(polynomial_coeff_1 - polynomial_coeff_2);

for i = 1:4
    disp('Compare coeff');
    disp(polynomial_coeff_1(i))
    disp(polynomial_coeff_2(i))
    disp(polynomial_coeff_3(i))
    disp(simplify(polynomial_coeff_1(i) - polynomial_coeff_2(i)))
    disp(simplify(polynomial_coeff_1(i) - polynomial_coeff_3(i)))
    fprintf('\n')
end



