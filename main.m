bodies = loadBodies('revJoint.mdl');
constraints = loadConstraints('revJoint.mdl');

t_curr = 1e-3;
tol = 1e-8;

q = NewtonRalphson(bodies, constraints, t_curr, tol)