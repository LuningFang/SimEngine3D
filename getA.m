% given input euler parameter p of size 4*1
% calculate matrix A
function A = getA(p)
e0 = p(1);
e = p(2:4);
A = (2*e0^2 - 1)*eye(3) + 2*(e*e' + e0*tensor(e));