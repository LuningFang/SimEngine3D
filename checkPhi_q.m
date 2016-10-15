bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

numC = 6; % total number of constraints
numB = 1; % total number of bodies

[Phi, ~, ~, Phi_q] = getPhi_RHS(bodies, constraints, numB, numC);
Phi_q_approx = zeros(size(Phi_q));

delta = 1e-5;

for i = 1:3
    u = zeros(3,1);
    u(i) = 1;
    newbodies = bodies;
    newbodies{1}{4} = newbodies{1}{4} + delta*u;
    [Phi_new, ~, ~, ~] = getPhi_RHS(newbodies, constraints, numB, numC);
    Phi_q_approx(:,i) = (Phi_new - Phi)/delta;
end

for i = 1:4
    u = zeros(4,1);
    u(i) = 1;
    newbodies = bodies;
    newbodies{1}{6} = newbodies{1}{6} + delta*u;
    [Phi_new, ~, ~, ~] = getPhi_RHS(newbodies, constraints, numB, numC);
    Phi_q_approx(:,i+3) = (Phi_new - Phi)/delta;
end

fprintf('differnce between approximated Phi_q and analytical Phi_q: \n');
Phi_q - Phi_q_approx
