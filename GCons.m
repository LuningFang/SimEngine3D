function results = GCons(num, constraint_info, body_info, time)

results = struct('i', 0, 'j', 0, 'phi',0, 'nu', 0, 'gamma', 0, 'phi_ri', zeros(1,3), 'phi_rj', zeros(1,3), 'phi_pi', zeros(1,4), 'phi_pj', zeros(1,4));

type = constraint_info{num}{4};
i = constraint_info{num}{2};
j = constraint_info{num}{3};
attr = constraint_info{num}{5};
ft = constraint_info{num}{6};

results.i = i;
results.j = j;

% evaluate derivatives of ft
syms t
ftdt = diff(ft, t, 1);
ftdtdt = diff(ft, t, 2);

% calculate derivatives of ft at time t
ft_v = ft(time);
ftdt_v = vpa(subs(ftdt, t, time));
ftdtdt_v = vpa(subs(ftdtdt, t, time));

% return nu
results.nu = ftdt_v;

% get position, euler parameters and orientation of body i
ri = body_info{i}{4};
ri_dt = body_info{i}{5};
pi = body_info{i}{6};
pi_dt = body_info{i}{7};
[omic_i,~,Ai] = getOmic(pi, pi_dt);

% handle the ground body where j = 0
if (j ~= 0)
    rj = body_info{j}{4};
    rj_dt = body_info{j}{5};
    pj = body_info{j}{6};
    pj_dt = body_info{j}{7};
else
    % ground body
    rj = [0, 0, 0]';  % origin of GRF
    rj_dt = [0, 0, 0]';
    pj = [1, 0, 0, 0]';
    pj_dt = [0, 0, 0, 0]';
end

[omic_j,~,Aj] = getOmic(pj, pj_dt);




if (strcmp(type,'DP1'))
    aibar = attr.ai;
    ai = Ai*aibar;
    ai_dt = getB(pi,aibar) * pi_dt;

    ajbar = attr.aj;
    aj = Aj*ajbar;
    aj_dt = getB(pj,ajbar) * pj_dt;
    
    results.gamma = -ai'*getB(pj_dt, ajbar)*pj_dt ...
        -aj'*getB(pi_dt, aibar)*pi_dt ...
        -2*ai_dt'*aj_dt + ftdtdt_v;
    
    results.phi = ai'*aj - ft_v;
    
    results.phi_ri = zeros(1,3);
    results.phi_rj = zeros(1,3);
    results.phi_pi = aj'*getB(pi,aibar);
    results.phi_pj = ai'*getB(pj,ajbar);

    % remove fields of Phi wrt rj and pj when j=0, ground
    if (j == 0)
        fields = {'phi_rj', 'phi_pj'};
        results = rmfield(results, fields);
    end
end

if (strcmp(type,'DP2'))
    aibar = attr.ai;
    ai = Ai*aibar;
    ai_dt = getB(pi,aibar) * pi_dt;
    sPi = attr.sPi;
    sQj = attr.sQj;
    
    dij = rj + Aj*sQj - (ri + Ai*sPi);
    dij_dt = rj_dt + getB(pj, sQj)*pj_dt - ri_dt - getB(pi, sPi)*pi_dt;

    results.phi = aibar'*Ai'*dij - ft_v;
    
    
    results.gamma = 2*omic_i'*tensor(aibar)*Ai'*(ri_dt - rj_dt) ...
          + 2*sQj'*tensor(omic_j)*Aj'*Ai*tensor(omic_i)*aibar ...
          - sPi'*tensor(omic_i)*tensor(omic_i)*aibar ...
          - sQj'*tensor(omic_j)*tensor(omic_j)*Aj'*Ai*aibar ...
          - dij'*Ai*tensor(omic_i)*tensor(omic_i)*aibar ...
          + ftdtdt_v;
      
     results.phi_ri = -aibar';
     results.phi_rj = aibar';
     results.phi_pi = dij'*getB(pi,aibar) - aibar'*getB(pi,sPi);
     results.phi_pj = aibar'*getB(pj,sQj);
     
end

% implement CD constraint
% TODO: rewrite the part that handle the ground body
if (strcmp(type,'CD'))
    % consider the case where body j is not the gound
    if (j ~= 0)
        sPi = attr.sPi;
        sQj = attr.sQj;
        c = attr.c;
        dij = rj + Aj*sQj - (ri + Ai*sPi);
        results.phi = c'*dij - ft_v;
        results.gamma = c'*getB(pi_dt, sPi)*pi_dt...
            -c'*getB(pj_dt, sQj)*pj_dt + ftdtdt_v;
        
        results.phi_ri = -c';
        results.phi_rj =  c';
        results.phi_pi = -c'*getB(pi,sPi);
        results.phi_pj =  c'*getB(pj,sQj);
    else
        % body j is the ground
        sPi = attr.sPi;
        c = attr.c;
        dij = rj - (ri + Ai*sPi);
        results.phi = c'*dij - ft_v;
        results.gamma = c'*getB(pi_dt, sPi)*pi_dt + ftdtdt_v;
        results.phi_ri = -c';
        results.phi_pi = -c'*getB(pi,sPi);
        % remove field of dPhi wrt rj and pj
        fields = {'phi_rj', 'phi_pj'};
        results = rmfield(results, fields);
    end
end