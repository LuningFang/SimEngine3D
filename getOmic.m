% get omega with given p and pdot
% if i == 1, output global value
% if i == 0, output local value
function omic = getOmic(p, pdot,i)
e0 = p(1);
e = p(2:4);

if i == 0
    G = [-e' -tensor(e)+e0*eye(3)];
    omic = 2*G*pdot;
end

if i == 1
    E = [-e, tensor(e) + e0*eye(3)];
    omic = 2*E*pdot;      
end