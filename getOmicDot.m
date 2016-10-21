function [omic_dot, omic_dot_bar] = getOmicDot(p, pddot)
e0 = p(1);
e = p(2:4);

G = [-e -tensor(e)+e0*eye(3)];
E = [-e, tensor(e) + e0*eye(3)];
omic_dot = 2*E*pddot;
omic_dot_bar = 2*G*pddot;