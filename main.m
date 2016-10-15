bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

numC = 6; % total number of constraints
numB = 1; % total number of bodies

[Phi, ~, ~, Phi_q] = getPhi_RHS(bodies, constraints, numB, numC);

delta = 1e-3;
newbodies = bodies;
%newbodies{1}{4} = newbodies{1}{4} + delta*[1;0;0];
newbodies{1}{6} = newbodies{1}{6} + delta*[1;0;0;0];
[Phi_new, ~, ~, ~] = getPhi_RHS(newbodies, constraints, numB, numC);

Phi_q_approx = (Phi_new - Phi)/delta
Phi_q(:,4)
