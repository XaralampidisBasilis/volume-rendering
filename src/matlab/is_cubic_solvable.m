clc, clear

% Define symbolic variables
syms c0 c1 c2 c3 
syms s0 s1 s2
syms v0 v1 v2 

assume([c0 c1 c2 c3], 'real')
assume([s0 s1 s2], 'real')
assume([v0 v1 v2], 'real')

% S = [c0 s0 s0^2 s0^3; c0 s1 s1^2 s1^3; c0 s3 s3^2 s3^3];
S = [0 0^2 0^3; 0.5 0.5^2 0.5^3; 1 1^2 1^3];
V = [v0; v1; v2];
C0 = [c0; c0; c0];

C = simplify(S \ (V - C0));