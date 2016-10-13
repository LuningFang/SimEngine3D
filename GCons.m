function results = GCons(num, constraint_info, body_info)
results = struct('phi',0, 'nu', 0, 'gamma', 0, 'phi_ri', zeros(1,3), 'phi_rj', zeros(1,3), 'phi_pi', zeros(1,4), 'phi_pj', zeros(1,4));
%TODO: handle f(t)
type = constraint_info{num}{4};
i = constraint_info{num}{2};
j = constraint_info{num}{3};
attr = constraint_info{num}{5};
ft = constraint_info{num}{6};

%    if (i ~= 0 && j ~= 0)
ri = body_info{i}{4};
rj = body_info{j}{4};
ri_dt = body_info{i}{5};
rj_dt = body_info{j}{5};
pi = body_info{i}{6};
pj = body_info{j}{6};
pi_dt = body_info{i}{7};
pj_dt = body_info{j}{7};

omic_i = getOmic(pi, pi_dt,0);

omic_j = getOmic(pj, pj_dt,0);

Ai = getA(pi);
Aj = getA(pj);


%    end
% need input for f_dt_dt
f_dt_dt = 0;


% assume t = 0.1, take care of this later
t = 0.1;

% do something about ground!!!
if (strcmp(type,'DP2'))
    aibar = attr.ai;
    ai = Ai*aibar;
    ai_dt = getB(pi,aibar) * pi_dt;
    sPi = attr.sPi;
    sQj = attr.sQj;
    
    dij = rj + Aj*sQj - (ri + Ai*sPi);
    dij_dt = rj_dt + getB(pj, sQj)*pj_dt - ri_dt - getB(pi, sPi)*pi_dt;
    
    test1 = getB(pj, sQj)*pj_dt
    
    dij_dt2 = rj_dt + Aj*tensor(omic_j)*sQj - ri_dt - Ai*tensor(omic_i)*sPi;
    test_2 = Aj*tensor(omic_j)*sQj
    results.phi = aibar'*Ai'*dij - ft(t);
    
    
    results.gamma = 2*omic_i'*tensor(aibar)*Ai'*(ri_dt - rj_dt) ...
          + 2*sQj'*tensor(omic_j)*Aj'*Ai*tensor(omic_i)*aibar ...
          - sPi'*tensor(omic_i)*tensor(omic_i)*aibar ...
          - sQj'*tensor(omic_j)*tensor(omic_j)*Aj'*Ai*aibar ...
          - dij'*Ai*tensor(omic_i)*tensor(omic_i)*aibar ...
          + f_dt_dt;
      
     gamma_hat = -ai'*getB(pj_dt, sQj)*pj_dt + ai'*getB(pi_dt, sPi)*pi_dt - dij'*getB(pi_dt,aibar)*pi_dt - 2*ai_dt'*dij_dt + f_dt_dt;
      
     results.phi_ri = -aibar';
     results.phi_rj = aibar';
     results.phi_pi = dij'*getB(pi,aibar) - aibar'*getB(pi,sPi);
     results.phi_pj = aibar'*getB(pj,sQj);
     
end