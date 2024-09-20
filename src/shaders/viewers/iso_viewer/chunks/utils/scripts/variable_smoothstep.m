% https://www.peterstock.co.uk/games/adjustable_smoothstep/

syms t p q r g c T P Q G C;
assume([t p q g T P Q G], 'real')
assume(0 < t & t < 1)
assume(0 < p & p < 1)
assume(0 < q & q < 1)

f_t = simplify(q/p * t^2 * (1 + c)/(t + p*c));
f_T = simplify(subs(f_t, t, p/q /(1+c) * T));

pretty(f_T)

s = q/p*t*(1+c);
c = q*c*(1+c);
f_s = simplify(s^2 / (s + c));
disp(simplify(f_t - f_s))


%%
h_t = finverse(f_t, t);
h_t = simplify(subs(h_t, [p, q], [q, p]));
h_T = simplify(subs(h_t, t, p/q *(1+c) * T));
pretty(h_t)

%s = q/p * t / (1+c);
%c = q*c / (1+c);
%h_s = simplify(1/2 * s * (1 + sqrt(1 + 4*c/s)));
%pretty(h_s)

%disp(simplify(h_t - h_s))

%%
a1 = simplify(subs(1/(p/q /(1+c)), c, (p*g - q)/(2*q - p*g)));
a2 = simplify(subs(q*c*(1+c), c, (p*g - q)/(2*q - p*g)));

pretty([a1, a2])

b1 = simplify(subs(1/((1+c) * p/q), c, (q*g - p)/(2*p - q*g)));
b2 = simplify(subs(q*c, c, (q*g - p)/(2*p - q*g)));

pretty([b1, b2])


