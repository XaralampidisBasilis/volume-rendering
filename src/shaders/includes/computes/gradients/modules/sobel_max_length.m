% Define Sx, Sy, and Sz as given
Sx = [ +1.0, +2.0, +1.0, ...
       +2.0, +4.0, +2.0, ...
       +1.0, +2.0, +1.0, ...
        0.0,  0.0,  0.0, ...
        0.0,  0.0,  0.0, ...
        0.0,  0.0,  0.0, ...
       -1.0, -2.0, -1.0, ...
       -2.0, -4.0, -2.0, ...
       -1.0, -2.0, -1.0];

Sy = [ +1.0, +2.0, +1.0, ...
        0.0,  0.0,  0.0, ...
       -2.0, -4.0, -0.0, ...
       +2.0, +4.0, +2.0, ...
        0.0,  0.0,  0.0, ...
       -2.0, -4.0, -2.0, ...
       +1.0, +2.0, +1.0, ...
        0.0,  0.0,  0.0, ...
       -1.0, -2.0, -1.0];
 
Sz = [ +1.0,  0.0, -1.0,  ...
       +2.0,  0.0, -2.0,  ...
       +1.0,  0.0, -1.0,  ...
       +2.0,  0.0, -2.0,  ...
       +4.0,  0.0, -4.0,  ...
       +2.0,  0.0, -2.0,  ...
       +1.0,  0.0, -1.0,  ...
       +2.0,  0.0, -2.0,  ...
       +1.0,  0.0, -1.0];

S = Sx' * Sx + Sy' * Sy + Sz' * Sz;
d = eig(S);

% Define the objective function
objective = @(r) -sqrt(r' * S * r); % Negate because we use fmincon for minimization

% Define the constraints
n = size(S, 1); % Number of dimensions
lb = zeros(n, 1); % Lower bound: vector of zeros
ub = ones(n, 1); % Upper bound: vector of ones

% Set optimization options
options = optimoptions('fmincon', 'Display', 'none', 'Algorithm', 'sqp');

% Equality constraint to ensure the 14th value of r is zero
Aeq = zeros(1, n);
Aeq(14) = 1;
beq = 0;

% Run optimization 1000 times and find the greatest maximum value
num_trials = 1000;
best_r_max = [];
best_max_value = -Inf;

for i = 1:num_trials
    % Initial guess
    r0 = rand(n, 1);
    r0(14) = 0; % Ensure the initial guess also satisfies the constraint

    % Solve the optimization problem
    [r_max, fval] = fmincon(objective, r0, [], [], Aeq, beq, lb, ub, [], options);

    % Since we minimized the negative, take the negative of fval to get the maximum
    max_value = -fval;

    % Update the best result if this one is better
    if max_value > best_max_value
        best_max_value = max_value;
        best_r_max = r_max;
    end
end

% Display the best results
disp('The best vector r that maximizes l(r) is:');
disp(best_r_max);
disp('The maximum value of l(r) is:');
disp(best_max_value);
disp(best_max_value ^ 2);

    
    