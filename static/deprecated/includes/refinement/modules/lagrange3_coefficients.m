%% Analytical solution mathematically

syms t0 t1 t2 f0 f1 f2;

assume([t0 t1 t2 f0 f1 f2], 'real')
assume(t0 <= t1 & t1 <= t2)

% Define symbolic vectors for t, f, 
t = [t0; t1; t2];
f = [f0; f1; f2];

% Define the matrix A symbolically
A = [1, t0, t0^2;
     1, t1, t1^2;
     1, t2, t2^2];

% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2
pol_coeff = simplify(A \ f);
disp(pol_coeff)


%% Search for an efficient nymerically stable solution

parenthesis = cell(1, 3);
terms = cell(1, 3);
mult = pol_coeff;
fpol_coeff = pol_coeff;

for i = 1:3
        
    [parenthesis{i}, terms{i}] = coeffs(simplify(pol_coeff(i)), f);
    
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

    fpol_coeff(i) = dot(parenthesis{i} .* mult(i), terms{i});
end

Parenthesis = [parenthesis{1}; parenthesis{2}; parenthesis{3}];
Terms = [terms{1}; terms{2}; terms{3}];

disp(Parenthesis)
disp(Terms)
%disp(simplify(fpol_coeff))

%% Confirm numerically stable computation for GPU

% Cross differences products
t_cross_prod = [
    (t0 - t1) * (t0 - t2);
    (t1 - t0) * (t1 - t2);
    (t2 - t0) * (t2 - t1);
];

% Partial products
t_part_prod = [
    (t1 * t2);
    (t0 * t2);
    (t0 * t1);
];

% Sum of two components
t_comp_sum = [
    (t1 + t2);
    (t0 + t2);
    (t0 + t1);
];


% Define the matrix composed of t_part_prod, t_comp_sum, and a row of ones
t_matrix = [
    t_part_prod(1), - t_comp_sum(1), 1;
    t_part_prod(2), - t_comp_sum(2), 1;
    t_part_prod(3), - t_comp_sum(3), 1;
];

% Compute weighted f values
f_weighted = [f0; f1; f2] ./ t_cross_prod;
f_weighted = simplify(f_weighted);

% Perform matrix-vector multiplication to compute the coefficients
pol_coeff_2 = t_matrix' * f_weighted;

% Display the resulting coefficients
pol_coeff_2 = simplify(pol_coeff_2);


disp(simplify(pol_coeff - pol_coeff_2));

