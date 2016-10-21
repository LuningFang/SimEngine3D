close all
clc
clear all
global numB
bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

t0 = 0;
tol = 1e-5;
dt = 1e-3;
tend = 10;

% record the history of point O
history_O = cell(tend/dt,1);
info_O = struct('r', zeros(3,1), 'rdt', zeros(3,1), 'rddt', zeros(3,1),...
          'omic', zeros(3,1), 'omicdt', zeros(3,1));
% record the history of point Q
sQ = [-2;0;0];
history_Q = cell(tend/dt,1);
info_Q = struct('r', zeros(3,1), 'rdt', zeros(3,1), 'rddt', zeros(3,1));
      
timeStep = 1;
for t = t0+dt:dt:tend
    % calculate position at t+1
    q = NewtonRalphson(bodies, constraints, t, tol);
    if (mod(timeStep,1000) == 0)
        fprintf('t= %f\n',t);
    end
    
    info_O.r = q(1:3);
    % update position for the bodies
    for i = 1:numB
        bodies{i}{4} = q((i-1)*3+1:3*i);
        bodies{i}{6} = q(3*numB+(i-1)*4+1:3*numB+i*4);   
    end
    
    % update phi_q
    [~, Nu, ~, Phi_q] = getPhi_RHS(bodies, constraints, t);
    % velocity analysis
    qdot = Phi_q\Nu;

    info_O.rdt = qdot(1:3);
    [omic_bar, omic_O, A] = getOmic(q(4:7), qdot(4:7));
    info_O.omic = omic_O;
    % position for point Q
    info_Q.r = q(1:3) + A*sQ;
    info_Q.rdt = qdot(1:3) + A*tensor(omic_bar)*sQ;
    
    
    % update velocity for the bodies
    for i = 1:numB
        bodies{i}{5} = qdot((i-1)*3+1:3*i);
        bodies{i}{7} = qdot(3*numB+(i-1)*4+1:3*numB+i*4);
    end
    
    %update phi_q
    [~, ~, Gamma, Phi_q] = getPhi_RHS(bodies, constraints, t);
    qddot = Phi_q\Gamma;
    
    info_O.rddt = qddot(1:3);
    [omic_dot, omic_dot_bar] = getOmicDot(q(4:7), qddot(4:7));
    info_O.omicdt = omic_dot;
    Addt = A*tensor(omic_dot_bar) + A*tensor(omic_bar)*tensor(omic_bar);
    info_Q.rddt = qddot(1:3) + Addt * sQ;
    %update q for next time step
    qk = q + qdot*dt + 1/2*qddot*dt^2;
    
    % update position for the bodies
    for i = 1:numB
        bodies{i}{4} = qk((i-1)*3+1:3*i);
        bodies{i}{6} = qk(3*numB+(i-1)*4+1:3*numB+i*4);   
    end    
    history_O{timeStep,1} = info_O;
    history_Q{timeStep,1} = info_Q;
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

figure(4)
subplot(3,1,1)
plot(timeArray, getArray(history_Q, 'r', 1));
xlabel('t(sec)');
ylabel('pos_x of point Q');
subplot(3,1,2)
plot(timeArray, getArray(history_Q, 'r', 2));
xlabel('t(sec)');
ylabel('pos_y of point Q');
subplot(3,1,3)
plot(timeArray, getArray(history_Q, 'r', 3));
xlabel('t(sec)');
ylabel('pos_z of point Q');

figure(5)
subplot(3,1,1)
plot(timeArray, getArray(history_Q, 'rdt', 1));
xlabel('t(sec)');
ylabel('velo_x of point Q');
subplot(3,1,2)
plot(timeArray, getArray(history_Q, 'rdt', 2));
xlabel('t(sec)');
ylabel('velo_y of point Q');
subplot(3,1,3)
plot(timeArray, getArray(history_Q, 'rdt', 3));
xlabel('t(sec)');
ylabel('velo_z of point Q');

figure(6)
subplot(3,1,1)
plot(timeArray, getArray(history_Q, 'rddt', 1));
xlabel('t(sec)');
ylabel('acc_x of point Q');
subplot(3,1,2)
plot(timeArray, getArray(history_Q, 'rddt', 2));
xlabel('t(sec)');
ylabel('acc_y of point Q');
subplot(3,1,3)
plot(timeArray, getArray(history_Q, 'rddt', 3));
xlabel('t(sec)');
ylabel('acc_z of point Q');
