syms t Vc V0 V1 S0 S1

assume(0 <= t & t <= 0.5);
assume(0 <= V0 & V0 <= 1);
assume(0 <= V1 & V1 <= 1);
assume(0 <= Vc & Vc <= 1);
assume(V0 < Vc & Vc <= V1);
assume(V0 < V1);
assume(0 < S0 );

% Define approximate Hermite interpolation polynomial V(t)
V_t = V0*(1-t) + V1*t + t/2*(S0*(1-t) - S1*t);

% Solve V(t) = Vc symbolically
symbolic_solutions = solve(V_t == Vc, t, "MaxDegree", 3, 'Real', true, "ReturnConditions", false);
disp('The symbolic solutions of V(t) = Vc are:');
disp(symbolic_solutions);
