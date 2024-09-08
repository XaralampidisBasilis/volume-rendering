syms t0 t1 t2 f0 f1 f2;

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
coeff = A \ b;
coeff = simplify(coeff);

% Display the result
disp('The symbolic coefficients are:');
pretty(coeff);

coeff_norm = subs(subs(subs(coeff, t0, 0), t1, 0.5), t2, 1);
disp('The normalized symbolic coefficients are:');
pretty(coeff_norm);