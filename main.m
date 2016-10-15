bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

[~, numC] = size(constraints); % total number of constraints
[~, numB] = size(bodies); % total number of bodies

[Phi, Nu, Gamma, Phi_q] = getPhi_RHS(bodies, constraints, numB, numC);

% stack r and p together to get q when solve linear system
% map back and change the value of bodies afterwards!!
Phi
Nu
Gamma
Phi_q