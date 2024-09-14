syms t0 t1 f0 f1;

assume([t0 t1 f0 f1], 'real')
assume(t0 <= t1)

% Define symbolic vectors for t, f, and f_prime
t = [t0; t1];
f = [f0; f1];

% Define the matrix A symbolically
A = [1, t0;
     1, t1];
    
% Solve for the coefficients (A * coeff = b) => coeff = A \ b
% coeff[1] + coeff[2] * t
p = simplify(A \ f);
disp(p)

%% Search for an efficient nymerically stable solution

p_coeffs = cell(1, 2);
p_terms = cell(1, 2);
mult = pol_coeff;
fp = p;

for i = 1:2
        
    [p_coeffs{i}, p_terms{i}] = coeffs(simplify(p(i)), f);
    
    % factor each parenthesis
    nonzeros_parenthesis = nonzeros(p_coeffs{i});
    nonzeros_idx = find(p_coeffs{i} ~= 0);
    
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
        p_coeffs{i}(nonzeros_idx(k)) = simplify(prod(repsetdiff(factors{k}, common)), 'Steps', 100);
    end
    mult(i) = prod(common);

    fp(i) = dot(p_coeffs{i}, p_terms{i}.* mult(i));
end

p_terms_mat = [p_coeffs{1}; p_coeffs{2}];
p_temrs_mat = [p_terms{1}; p_terms{2}];

disp(mult)
disp(p_terms_mat)
disp(p_temrs_mat)
disp(simplify(fp))
