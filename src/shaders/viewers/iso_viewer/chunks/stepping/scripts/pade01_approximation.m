clear, clc
syms a0 a1 a2 b1 x x0 f00 f10 f20 f30 fc
assume([a0 a1 a2 b1 x x0 f00 f10 f20 f30 fc], 'real')

taylor = f00 + f10 / factorial(1) * (x - x0) + f20 / factorial(2) * (x - x0)^2 + f30 / factorial(3) * (x - x0)^3;
pade01 = pade(taylor, x, 'Order', [0 1], 'ExpansionPoint', x0);
