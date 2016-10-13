% calculate the B matrix
% input:
% p - euler parameter 4*1
% a - local vector 3*1
function B = getB(p,a)
e0 = p(1);
e = p(2:4);

B = 2*[(e0*eye(3))*a e*a' - (e0*eye(3) + tensor(e))*tensor(a)];