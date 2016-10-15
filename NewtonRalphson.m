function q = NewtonRalphson(bodies, constraints, t_curr, tol)
bodyInfo = bodies;
[~, numB] = size(bodyInfo);

q0 = zeros(7*numB,1);
for i = 1:numB
    q0((i-1)*3+1:3*i) = bodyInfo{i}{4};
    q0(3*numB+(i-1)*4+1:3*numB+i*4) = bodyInfo{i}{6};   
end

q0

err = 100;
itr = 1;
qk = q0;
while abs(err) > tol
    [Phi, ~, ~, Phi_q] = getPhi_RHS(bodyInfo, constraints, t_curr);
    
    qnew = qk - inv(Phi_q)*Phi;
    err = norm(qnew - qk,2);
    

%    fprintf('%d,%f,%f,%.10g,%.10g\n', itr, xk, fk, xk -1.1347241384, err);
    fprintf('%d, %.10g\n', itr, err);
    
    
    qk = qnew;
    for i = 1:numB
        bodyInfo{i}{4} = qnew((i-1)*3+1:3*i);
        bodyInfo{i}{6} = qnew(3*numB+(i-1)*4+1:3*numB+i*4);   
    end
    itr = itr + 1;
    
end

q = qk;