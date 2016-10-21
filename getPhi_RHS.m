function [Phi, Nu, Gamma, Phi_q] = getPhi_RHS(bodies, constraints, time)

[~, numC] = size(constraints); % total number of constraints
[~, numB] = size(bodies); % total number of bodies
% dimension of Phi, including p'p-1
Phi = zeros(numC+numB,1);
Phi_q = zeros(numC+numB, 7*numB);
Nu = zeros(numC+numB,1);
Gamma = zeros(numC+numB,1);

% Phi_q
% [Phi_r1 Phi_r2 ... Phi_rb Phi_p1 Phi_p2 ... Phi_pb]
for k = 1:numC
    results = GCons(k, constraints, bodies, time);
    Phi(k) = results.phi;
    Gamma(k) = results.gamma;
    Nu(k) = results.nu;
    
    i = results.i;
    j = results.j;
    
    Phi_q(k, 3*(i-1)+1: 3*i) = results.phi_ri;
    Phi_q(k, 3*numB + 4*(i-1)+1:3*numB + 4*i) = results.phi_pi;
    
    if (j~=0)
        Phi_q(k, 3*(j-1)+1: 3*j) = results.phi_rj;
        Phi_q(k, 3*numB + 4*(j-1)+1:3*numB + 4*j) = results.phi_pj;
    end
    
end

% add p'*p = 1 constraints
for m = 1:numB
    p = bodies{1}{6};
    dp = bodies{1}{7};
    Phi(numC+m) = p'*p - 1;
    Phi_p = zeros(1, 7*numB);
    Phi_p(3*numB+4*(m-1)+1:3*numB+4*m) = 2*p';
    Phi_q(numC+m,:) = Phi_p;
    Nu(numC+m) = 0;
    Gamma(numC+m) = -2*(dp')*dp;
end