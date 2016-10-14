% get omega with given p and pdot
function [omic_bar, omic, A] = getOmic(p, pdot)
e0 = p(1);
e = p(2:4);

G = [-e -tensor(e)+e0*eye(3)];
E = [-e, tensor(e) + e0*eye(3)];
A = E*G';

omic_bar = 2*G*pdot;
omic = 2*E*pdot;