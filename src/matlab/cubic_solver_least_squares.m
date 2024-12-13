clear, clc
syms cx cy cz cw t v 
assume([cx cy cz cw t v], 'real')

fun = cx + cy * t + cz * t^2 + cw * t^3;
fun = cx / 2 + cy * t + cz * t^2 / 2 + t^3;

error = (fun)^2;
deriv = diff(error, t);

[t_coeffs, t_terms] = coeffs(deriv, t);
t_coeffs = simplify(t_coeffs);

disp([t_coeffs(:), t_terms(:)])