syms t t0 t1 f0 f1 g0 g1 s s0 s1 a b e;
assume([t t0 t1 f0 f1 g0 g1 s s0 s1 a b], 'real')

L = [1, 0, 0, 0;
      b, a, 0, 0;
      b^2, 2*b*a, a^2, 0;
      b^3, 3*b^2*a, 3*b*a^2, a^3];
  
T = [1, t0, t0^2,   t0^3;
      1, t1, t1^2,   t1^3;
      0,  1, 2*t0, 3*t0^2;
      0,  1, 2*t1, 3*t1^2];
 
S = [1, s0, s0^2,   s0^3;
      1, s1, s1^2,   s1^3;
      0,  1, 2*s0, 3*s0^2;
      0,  1, 2*s1, 3*s1^2];
 
A = simplify((S * (transpose(L)) / T));
A = simplify(subs(A, t0, a * s0 + b));
A = simplify(subs(A, t1, a * s1 + b));


