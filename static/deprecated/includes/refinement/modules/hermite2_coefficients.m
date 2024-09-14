syms t0 t1 f0 f1 g0 g1;

assume([t0 t1 f0 f1 g0 g1], 'real')
assume(t0 <= t1)

% Define symbolic vectors for t, f, and f_prime
t = [t0; t1];
f = [f0; f1];
g = [g0; g1];

% Construct the right-hand side vector b (function values and derivatives)
v = [f(:); g(:)];

% Define the matrix A symbolically
pp = [1, t0, t0^2,   t0^3;
     1, t1, t1^2,   t1^3;
     0,  1, 2*t0, 3*t0^2;
     0,  1, 2*t1, 3*t1^2];
    
% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2 + coeff[4] * t^3
pol_coeff = simplify(pp \ v);
disp(pol_coeff)

%% Search for an efficient nymerically stable solution

[numer, denom] = numden(pol_coeff);

parenthesis = cell(1, 4);
terms = cell(1, 4);
mult = pol_coeff;
fnumer = numer;

for i = 1:4
        
    [parenthesis{i}, terms{i}] = coeffs(simplify(numer(i)), v);
    
    % factor each parenthesis
    nonzeros_parenthesis = nonzeros(parenthesis{i});
    nonzeros_idx = find(parenthesis{i} ~= 0);
    
    num_terms = length(nonzeros_parenthesis);
    factors = cell(1, num_terms);
    
    factors{1} = factor(nonzeros_parenthesis(1));
    common = factors{1};
    
    % find common factors
    for k = 2:num_terms
        factors{k} = factor(nonzeros_parenthesis(k));
        common = repintersect(common, factors{k});
    end
    
    % remove common factors
    for k = 1:num_terms
        parenthesis{i}(nonzeros_idx(k)) = simplify(prod(repsetdiff(factors{k}, common)), 'Steps', 100);
    end
    mult(i) = prod(common);

    fnumer(i) = dot(parenthesis{i} .* mult(i), terms{i});
end

Parenthesis = [parenthesis{1}; parenthesis{2}; parenthesis{3}; parenthesis{4}];
Terms = [terms{1}; terms{2}; terms{3}; terms{4}];

disp(Parenthesis)
disp(Terms)
disp(simplify(fnumer./denom))


%% Search for an efficient nymerically stable solution
% this solution is more symmetric

P = simplify(Parenthesis .* [-1.0; 1.0; -1.0; 1.0] .*[-1.0, 1.0, 1.0/(t0-t1), 1.0/(t0-t1)]);

K = [3     3     9     9;
     1     1     3     3;
     1     1     3     3;
     3     3     9     9] / 3;

pp = [t1^3, t0^3, -t1^3, -t0^3;
     t1^2, t0^2, -t1^2, -t0^2;
     t1^1, t0^1, -t1^1, -t0^1;
     1.0,  1.0,  -1.0,  -1.0];
 
R = simplify(K .* P + pp / 2);
disp(2.0 * R)

% interesting property
disp(R(:,[1,2])-R(:,[3,4]))

%% other approach
syms e

P = simplify(Parenthesis .* [-1.0; 1.0; -1.0; 1.0] .*[-1.0, 1.0, 1.0/(t0-t1), 1.0/(t0-t1)]);
P = P + e * t0^3 * t1^3;

P_coeff = cell(size(P));
P_terms = cell(size(P));

for i = 1:size(P, 1)
    for j = 1:size(P, 2)
        
    [P_coeff{i, j}, P_terms{i, j}] = coeffs(P(i, j), [t0, t1], 'All');
    P_coeff{i, j} = subs(P_coeff{i, j}, e, 0);
    P_coeff{i, j} = P_coeff{i, j}(:);
    end
end
P = subs(P, e, 0);

P_terms_vec = P_terms{1,1}(:);
P_coeff_vec = P_coeff(:);
P_coeff_mat = [P_coeff_vec{:}];
nonzero_rows = ~all(P_coeff_mat == 0, 2);

%% other solution
syms e0 e1 e2 e3

B = simplify(Parenthesis .* [-1.0; 1.0; -1.0; 1.0] .*[-1.0, 1.0, 1.0/(t0-t1), 1.0/(t0-t1)]);

e_vec = [e0; e1; e2; e3];
p0 = [1; t0; t0^2; t0^3];
p1 = [1; t1; t1^2; t1^3];

tensor_prod = p0 * p1.';
pp = tensor_prod + diag(e_vec);
pp_det = det(tensor_prod + diag(e_vec));
[pp_det_t, pp_det_e] = coeffs(pp_det, e_vec);

M = linsolve(pp, B);

[M_numer, M_denom] = numden(M);
M_coeff = cell(size(M_numer));
M_terms = cell(size(M_numer));

for i = 1:size(M_numer, 1)
    for j = 1:size(M_numer, 2)
        
    [M_coeff{i, j}, M_terms{i, j}] = coeffs(M_numer(i, j), [e0, e1, e2, e3]);
    M_coeff{i, j} = M_coeff{i, j}(:);
    M_terms{i, j} = M_terms{i, j}(:);
    
    end
end

M_coeff_vec = M_coeff(:);
M_coeff_mat = [M_coeff_vec{:}];

M_terms_vec = M_terms(:);
M_terms_mat = [M_terms_vec{:}];



%% Solution

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
disp(simplify(pol_coeff - polynomial_coeff_2))


