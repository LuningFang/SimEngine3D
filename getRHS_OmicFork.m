function [Nu, Gamma, R_bar] = getRHS_OmicFork(bodies, constraints, time)
global numB numC


R_bar = zeros(numC, 6*numB);
Nu = zeros(numC,1);
Gamma = zeros(numC,1);

% R_bar
% [Phi_r1 Phi_r2 ... Phi_rb Phi_omic1 Phi_omic2 ... Phi_omicb]
for k = 1:numC
    results = GConsOmicFork(k, constraints, bodies, time);
    Gamma(k) = results.gamma;
    Nu(k) = results.nu;
    
    i = results.i;
    j = results.j;
    
    R_bar(k, 3*(i-1)+1: 3*i) = results.phi_ri;
    R_bar(k, 3*numB + 3*(i-1)+1:3*numB + 3*i) = results.phi_omici;
    
    if (j~=0)
        R_bar(k, 3*(j-1)+1: 3*j) = results.phi_rj;
        R_bar(k, 3*numB + 3*(j-1)+1:3*numB + 3*j) = results.phi_omicj;
    end
    
end