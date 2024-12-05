syms t t0 t1 f0 f1 g0 g1 s s0 s1 a b e;

vars = [a, b];

[numer, denom] = numden(A);
numer = collect(simplify(numer), vars);

[num_rows, num_cols] = size(numer);
parenthesis = cell(num_rows, num_cols);
terms = cell(num_rows, num_cols);
multipliers = numer;
numer_factored = numer;

for i = 1:num_rows
    for j = 1:num_cols
        
        %[parenthesis{i, j}, terms{i, j}] = coeffs(simplify(numer(i, j)), a);
        [parenthesis{i, j}, terms{i, j}] = coeffs(simplify(numer(i, j) + e*a^5), a, 'All');
        parenthesis{i, j} = subs(parenthesis{i, j}, e, 0);
        
        % factor each parenthesis
        nonzeros_parenthesis = nonzeros(parenthesis{i, j});
        nonzeros_idx = find(parenthesis{i, j} ~= 0);
        
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
            parenthesis{i, j}(nonzeros_idx(k)) = simplify(prod(repsetdiff(factors{k}, common)), 'Steps', 100);
        end
        multipliers(i,j) = prod(common);

        numer_factored(i, j) = dot(parenthesis{i, j} .* multipliers(i,j), terms{i, j});
    end
end

Parenthesis = [parenthesis{1,:}; parenthesis{2,:}; parenthesis{3,:}; parenthesis{4,:}];

disp(simplify(numer_factored))
A_factored = numer_factored ./ denom;