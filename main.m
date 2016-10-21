bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

t0 = 0;
tol = 1e-5;
dt = 1e-3;
tend = 1;

[~, numB] = size(bodies);

Oy = [];
Oz = [];
timeStep = 1;
for t = t0+dt:dt:tend
    % calculate position at t+1
    q = NewtonRalphson(bodies, constraints, t, tol);
    if (mod(timeStep,1000) == 0)
        fprintf('t= %f, %.10g, %.10g\n',t, q(2), q(3));
    end
    Oy = [Oy; q(2)];
    Oz = [Oz; q(3)];
    % update position for the bodies
    for i = 1:numB
        bodies{i}{4} = q((i-1)*3+1:3*i);
        bodies{i}{6} = q(3*numB+(i-1)*4+1:3*numB+i*4);   
    end    
    % update phi_q
    [~, Nu, ~, Phi_q] = getPhi_RHS(bodies, constraints, t);
    % velocity analysis
    qdot = Phi_q\Nu;
    
    % update velocity for the bodies
    for i = 1:numB
        bodies{i}{5} = qdot((i-1)*3+1:3*i);
        bodies{i}{7} = qdot(3*numB+(i-1)*4+1:3*numB+i*4);
    end
    
    %update phi_q
    [~, ~, Gamma, Phi_q] = getPhi_RHS(bodies, constraints, t);
    qddot = inv(Phi_q)*Gamma;
    
    %update q for next time step
    qk = q + qdot*dt + 1/2*qddot*dt^2;
    
    % update position for the bodies
    for i = 1:numB
        bodies{i}{4} = qk((i-1)*3+1:3*i);
        bodies{i}{6} = qk(3*numB+(i-1)*4+1:3*numB+i*4);   
    end    
    
    timeStep = timeStep+1;
end

figure;
plot(Oy,Oz);
