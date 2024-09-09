syms t0 t1 t2 f0 f1 f2;

assume([t0 t1 t2 f0 f1 f2], 'real')

% Define symbolic vectors for t, f, 
t = [t0; t1; t2];
f = [f0; f1; f2];

% Construct the right-hand side vector b (function values)
b = f(:);

% Define the matrix A symbolically
A = [1, t0, t0^2;
     1, t1, t1^2;
     1, t2, t2^2];

% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2
polynomial_coeff_1 = simplify(A \ b);

% Compute dt and its cube, ensuring stability
% Compute the cross differences
dt = t([2,3,1]) - t([3,1,2]);  % equivalent to t.yzx - t.zxy in GLSL
tf = dt .* f;                  % Element-wise multiplication (.*)
dt3 = -prod(dt);               % Negative product of the cross differences

polynomial_coeff_2 = [
    dot(tf, t([2,3,1]) .* t([3,1,2]));      
    dot(tf, -t([2,3,1]) - t([3,1,2]));       
    dot(tf, [1, 1, 1])                     
] / dt3;

%3
[numer, denom] = numden(polynomial_coeff);
numer = collect(simplify(numer), [f0, f1, f2]);
parenthesis = arrayfun(@(x) flip(coeffs(x, [f0, f1, f2])), numer, 'UniformOutput', false);
factored = cellfun(@(array) arrayfun(@(symbolic) prod(factor(symbolic)), array), parenthesis, 'UniformOutput', false);
polynomial_coeff_3 = cellfun(@(array) dot(expand(array), [f0, f1, f2]), factored, 'UniformOutput', true) ./ denom;


for i = 1:3
    disp('Compare coeff');
    disp(polynomial_coeff_1(i))
    disp(polynomial_coeff_2(i))
    disp(polynomial_coeff_3(i))
    disp(simplify(polynomial_coeff_1(i) - polynomial_coeff_2(i)))
    disp(simplify(polynomial_coeff_1(i) - polynomial_coeff_3(i)))
    fprintf('\n')
end

