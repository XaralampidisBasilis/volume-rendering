syms c t V0 V1 S0 S1

assume(0 <= t & t <= 1);
assume(0 <= V0 & V0 <= 1);
assume(0 <= V1 & V1 <= 1);
%assume(-2 <= S0 & S0 <= 2);
%assume(-2 <= S1 & S1 <= 2);
assume(0 <= c & c <= 1);

% Define Hermite basis functions
h00 = 2*t^3 - 3*t^2 + 1;
h10 = t^3 - 2*t^2 + t;
h01 = -2*t^3 + 3*t^2;
h11 = t^3 - t^2;

% Define Hermite interpolation polynomial V(t)
V_t = h00 * V0 + h10 * S0 + h01 * V1 + h11 * S1;

% Compute the derivative of V(t)
V_t_prime = diff(V_t, t);

% Display the derivative polynomial
%disp('The derivative of V(t) is:');
%disp(V_t_prime);

% Simplify the derivative polynomial (optional)
V_t_prime_simplified = simplify(V_t_prime);
%disp('The simplified derivative of V(t) is:');
%disp(V_t_prime_simplified);

% Solve V(t) = c symbolically
symbolic_solutions = solve(V_t == c, t, "MaxDegree", 3, 'Real', true, "ReturnConditions", true);
disp('The symbolic solutions of V(t) = c are:');
disp(symbolic_solutions);

% Solve V'(t) = 0 symbolically
symbolic_solutions_prime = solve(V_t_prime == 0, t, "MaxDegree", 2, 'Real', true, "ReturnConditions", false);
disp('The symbolic solutions of V''(t) = 0 are:');
disp(symbolic_solutions_prime);

t1_value = symbolic_solutions_prime(1);
t2_value = symbolic_solutions_prime(2);
symbolic_value_1 = simplify(subs(V_t, {t}, {t1_value}));
symbolic_value_2 = simplify(subs(V_t, {t}, {t2_value}));

disp('The V(t) for t solving V''(t) = 0 are:');
disp(symbolic_value_1);
disp(symbolic_value_2);

% Define specific values for V0, V1, S0, and S1
%V0_value = 1.0;
%V1_value = 2.0;
%S0_value = 3.0; % Example: G0 * (P1 - P0)
%S1_value = 4.0; % Example: G1 * (P1 - P0)

% Substitute the values into the symbolic solutions
numerical_solutions = double(subs(symbolic_solutions_prime, {V0, V1, S0, S1}, {V0_value, V1_value, S0_value, S1_value}));
disp('The numerical solutions of V''(t) = 0 with specific values are:');
disp(numerical_solutions);
