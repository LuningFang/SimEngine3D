% get omega with given p and pdot
% if i == 1, output global value
% if i == 0, output local value
function omic = getOmic(p, pdot,i)
e0 = p(1);
e = p(2:4);

G = [-e -tensor(e)+e0*eye(3)];
E = [-e, tensor(e) + e0*eye(3)];

if i == 0
    omic = 2*G*pdot;
end

if i == 1
    omic = 2*E*pdot;      
end