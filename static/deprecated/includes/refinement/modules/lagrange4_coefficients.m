%% Analytical solution mathematically

syms t0 t1 t2 t3 f0 f1 f2 f3;

assume([t0 t1 t2 t3 f0 f1 f2 f3], 'real')
assume(t0 <= t1 & t1 <= t2 & t2 <= t3)

% Define symbolic vectors for t, f, 
t = [t0; t1; t2; t3];
f = [f0; f1; f2; f3];

% Define the matrix A symbolically
A = [1, t0, t0^2, t0^3;
     1, t1, t1^2, t1^3;
     1, t2, t2^2, t2^3;
     1, t3, t3^2, t3^3];

% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t + coeff[3] * t^2 + coeff[3] * t^3
pol_coeff = simplify(A \ f);
disp(pol_coeff)

%% Search for an efficient nymerically stable solution

parenthesis = cell(1, 4);
terms = cell(1, 4);
mult = pol_coeff;
fpol_coeff = pol_coeff;

for i = 1:4
        
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

Parenthesis = [parenthesis{1}; parenthesis{2}; parenthesis{3}; parenthesis{4}];
Terms = [terms{1}; terms{2}; terms{3}; terms{4}];

disp(Parenthesis)
disp(Terms)
disp(simplify(fpol_coeff))

%% Confirm numerically stable computation for GPU

% Cross differences products (t_cross_prod)
t_cross_prod = [
    (t0 - t1) * (t0 - t2) * (t0 - t3);
    (t1 - t0) * (t1 - t2) * (t1 - t3);
    (t2 - t0) * (t2 - t1) * (t2 - t3);
    (t3 - t0) * (t3 - t1) * (t3 - t2);
];

% Partial products (t_part_prod)
t_part_prod = [
    t1 * t2 * t3;
    t0 * t2 * t3;
    t0 * t1 * t3;
    t0 * t1 * t2;
];

% Mixed sums of double products (t_mixed_sum)
t_mixed_sum = [
    (t1 * t2 + t2 * t3 + t3 * t1);
    (t0 * t2 + t2 * t3 + t3 * t0);
    (t0 * t1 + t1 * t3 + t3 * t0);
    (t0 * t1 + t1 * t2 + t2 * t0);
];

% Sum of three components (t_comp_sum)
t_comp_sum = [
    (t1 + t2 + t3);
    (t0 + t2 + t3);
    (t0 + t1 + t3);
    (t0 + t1 + t2);
];


% Define the matrix composed of t_part_prod, -t_mixed_sum, t_comp_sum, and -1.0
t_matrix = [
    -t_part_prod(1), t_mixed_sum(1), -t_comp_sum(1), 1;
    -t_part_prod(2), t_mixed_sum(2), -t_comp_sum(2), 1;
    -t_part_prod(3), t_mixed_sum(3), -t_comp_sum(3), 1;
    -t_part_prod(4), t_mixed_sum(4), -t_comp_sum(4), 1;
];

% Compute weighted f values
f_weighted = [f0; f1; f2; f3] ./ t_cross_prod;

% Perform matrix-vector multiplication to compute the coefficients
pol_coeff_2 = t_matrix' * f_weighted;

% Simplify the resulting coefficients
pol_coeff_2 = simplify(pol_coeff_2);

disp(simplify(pol_coeff - pol_coeff_2))


