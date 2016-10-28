close all
clc
clear all
global numB
bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

t0 = 0;
tol = 1e-5;
dt = 1e-3;
tend = 5;

% record the history of point O
history_O = cell(tend/dt,1);
info_O = struct('r', zeros(3,1), 'rdt', zeros(3,1), 'rddt', zeros(3,1),...
          'omic', zeros(3,1), 'omicdt', zeros(3,1));
timeStep = 1;
for t = t0+dt:dt:tend
    
    % calculate position at t+1
    q = NewtonRalphson(bodies, constraints, t, tol);
    if (mod(timeStep,1000) == 0)
        fprintf('t= %f\n',t);
    end
    
    info_O.r = q(1:3);
    % update position q for the bodies
    for i = 1:numB
        bodies{i}{4} = q((i-1)*3+1:3*i);
        bodies{i}{6} = q(3*numB+(i-1)*4+1:3*numB+i*4);   
    end
    
    % update phi_q
    [Nu, ~, R_bar] = getRHS_OmicFork(bodies, constraints, t);
    % velocity analysis qbar = [rdot, omic_bar] 6nb*1
    qbar = R_bar\Nu;

    info_O.rdt = qbar(1:3);
    info_O.omic = qbar(4:6);
    % velocity for qdot = [rdot, pdot] 7nb*1
    qdot = zeros(size(q));
    % update velocity (rdot and pdot) for the bodies
    for i = 1:numB
        qdot((i-1)*3+1:3*i) = qbar((i-1)*3+1:3*i);
        bodies{i}{5} = qbar((i-1)*3+1:3*i);
        pdot = getPdot(q(3*numB+(i-1)*4+1:3*numB+i*4), qbar(3*numB+(i-1)*3+1:3*numB+i*3));
        bodies{i}{7} = pdot;
        qdot(3*numB+(i-1)*4+1:3*numB+i*4) = pdot;
    end
    
    %update phi_q
    [~, Gamma, R_bar] = getRHS_OmicFork(bodies, constraints, t);
    % acceleration qbardot = [rddot, omicdot] 6nb*1
    qbardot = R_bar\Gamma;
    
    qddot = zeros(size(q));
    info_O.rddt = qbardot(1:3);
    info_O.omicdt = qbardot(4:6);
    
    % update acceleration (rddot and pddot) for the bodies
    for i = 1:numB
        qddot((i-1)*3+1:3*i) = qbardot((i-1)*3+1:3*i);
        pdot = getPdot(q(3*numB+(i-1)*4+1:3*numB+i*4), qbardot(3*numB+(i-1)*3+1:3*numB+i*3));
        qddot(3*numB+(i-1)*4+1:3*numB+i*4) = pdot;
    end
    

    
    % TODO: convert back
    %update q for next time step
    qk = q + qdot*dt + 1/2*qddot*dt^2;
    
    % update position for the bodies
    for i = 1:numB
        bodies{i}{4} = qk((i-1)*3+1:3*i);
        bodies{i}{6} = qk(3*numB+(i-1)*4+1:3*numB+i*4);   
    end    
    history_O{timeStep,1} = info_O;
    
    timeStep = timeStep+1;
end

timeArray = (dt:dt:tend)';
OomicX = getArray(history_O, 'omic', 1);
OomicdtX = getArray(history_O, 'omicdt', 1);
OrY = getArray(history_O, 'r', 2);
OrZ = getArray(history_O, 'r', 3);
OrdtY = getArray(history_O, 'rdt', 2);
OrdtZ = getArray(history_O, 'rdt', 3);
OrddtY = getArray(history_O, 'rddt', 2);
OrddtZ = getArray(history_O, 'rddt', 3);
figure(1)
subplot(2,1,1)
plot(timeArray, OrY)
xlabel('t(sec)');
ylabel('pos_y of point O');
subplot(2,1,2)
plot(timeArray, OrZ)
xlabel('t(sec)');
ylabel('pos_z of point O');

figure(2)
subplot(3,1,1)
plot(timeArray, OrdtY)
xlabel('t(sec)');
ylabel('v_y of point O');
subplot(3,1,2)
plot(timeArray, OrdtZ)
xlabel('t(sec)');
ylabel('v_z of point O');
subplot(3,1,3)
plot(timeArray, OomicX)
xlabel('t(sec)');
ylabel('omic_x of point O');

figure(3)
subplot(3,1,1)
plot(timeArray, OrddtY)
xlabel('t(sec)');
ylabel('a_y of point O');
subplot(3,1,2)
plot(timeArray, OrddtZ)
xlabel('t(sec)');
ylabel('a_z of point O');
subplot(3,1,3)
plot(timeArray, OomicdtX)
xlabel('t(sec)');
ylabel('omicdt_x of point O');
