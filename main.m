[bodies, constraints] = readInput('pendulum.mdl');

results = GCons(2, constraints, bodies);