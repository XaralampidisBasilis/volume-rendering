syms a b c;


assume([a b c], 'real')

pol = a * t^2 + b * t + c;

discriminant = sqrt(b^2 - 4 * a * c);

t1 = (-b + discriminant) / (2 * a);
t2 = (-b - discriminant) / (2 * a);
t_linear = c / b;

a_sol1 = simplify(solve( t1 == t_linear, a));
a_sol2 = simplify(solve( t2 == t_linear, a));
