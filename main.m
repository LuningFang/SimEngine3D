[bodies, constraints] = readInput('revJoint.mdl');

numC = 6; % total number of constraints
numB = 1; % total number of bodies
Phi = zeros(numC,1);
Phi_q = zeros(numC, 7*numB);
Mu = zeros(numC,1);
Gamma = zeros(numC,1);

for i = 1:numC
results = GCons(i, constraints, bodies);
Phi(i) = results.phi;
Gamma(i) = results.gamma;
end

Phi
Gamma
