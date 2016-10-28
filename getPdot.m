% get G with given omicbar and p
function pdot = getPdot(p, omic_bar)
e0 = p(1);
e = p(2:4);

G = [-e -tensor(e)+e0*eye(3)];

pdot = 1/2*G'*omic_bar;