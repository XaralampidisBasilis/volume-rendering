syms t0 t1 f0 f1 f_prime0 f_prime1;

% Define symbolic vectors for t, f, and f_prime
t = [t0; t1];
f = [f0; f1];
f_prime = [f_prime0; f_prime1];

% Construct the right-hand side vector b (function values and derivatives)
b = [f(:); f_prime(:)];

% Define the matrix A symbolically
A = [1, t0, t0^2,   t0^3;
     1, t1, t1^2,   t1^3;
     0,  1, 2*t0, 3*t0^2;
     0,  1, 2*t1, 3*t1^2];
    
% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2 + coeff[4] * t^3
coeff = simplify(A \ b);

% Display the result
disp('The symbolic coefficients are:');
pretty(coeff);

coeff_norm = subs(subs(coeff, t0, 0), t1, 1);
disp('The normalized symbolic coefficients are:');
pretty(coeff_norm);