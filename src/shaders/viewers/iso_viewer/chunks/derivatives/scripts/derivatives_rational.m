clear, clc
syms x 
syms p0(x) p1(x) p2(x) p3(x)
syms n0(x) n1(x) n2(x) n3(x)
syms d0(x) d1(x) d2(x) d3(x)

P = [p0; p1; p2; p3];
N = [n0; n1; n2; n3];
D = [d0,    0,    0,  0;
     d1,   d0,    0,  0;
     d2, 2*d1,   d0,  0;
     d3, 3*d2, 3*d1, d0];

D0 = diag(diag(D));
LD = D - D0;
ND = D0\N;
LDD = D0\LD;
Y = ND - LDD * P; % recursive formula X == Y

%%
syms b0 b1 b2 b3

B = [b0 b1 b2 b3;
    b1 2*b2 3*b3 0;
    2*b2 6*b3 0 0;
    6*b3 0 0 0];
