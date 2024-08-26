
syms a00 a11 a01

assume(a00 > 0);
assume(a11 > 0);
assume(a01 > 0);

x1 = (a00 + a11 + 2*a01) / (a00 + 4*a11 + 5*a01);
x2 = (3/a11)^(1/3);

symbolic_solutions = solve(x1 == x2, a11);
disp('The symbolic solutions are:');
disp(symbolic_solutions);