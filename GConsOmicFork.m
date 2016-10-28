function results = GConsOmicFork(num, constraint_info, body_info, time)

results = struct('i', 0, 'j', 0, 'phi',0, 'nu', 0, 'gamma', 0, 'phi_ri', zeros(1,3), 'phi_rj', zeros(1,3), 'phi_omici', zeros(1,3), 'phi_omicj', zeros(1,3));

type = constraint_info{num}{4};
i = constraint_info{num}{2};
j = constraint_info{num}{3};
attr = constraint_info{num}{5};
ft = constraint_info{num}{6};
ftdt = constraint_info{num}{7};
ftdtdt = constraint_info{num}{8};

results.i = i;
results.j = j;


% calculate derivatives of ft at time t
ft_v = ft(time);
ftdt_v = ftdt(time);
ftdtdt_v = ftdtdt(time);

% return nu
results.nu = ftdt_v;

% get position, euler parameters and orientation of body i
ri = body_info{i}{4};
ri_dt = body_info{i}{5};
pi = body_info{i}{6};
pi_dt = body_info{i}{7};
% calculate omic
[omic_i_bar,~,Ai] = getOmic(pi, pi_dt);


% handle the ground body where j = 0
if (j ~= 0)
    rj = body_info{j}{4};
    rj_dt = body_info{j}{5};
    pj = body_info{j}{6};
    pj_dt = body_info{j}{7};
    [omic_j_bar,~,Aj] = getOmic(pj, pj_dt);
else
    % ground body
    rj = [0, 0, 0]';  % origin of GRF
    rj_dt = [0, 0, 0]';
    pj = [1, 0, 0, 0]';
    pj_dt = [0, 0, 0, 0]';
    [omic_j_bar,~,Aj] = getOmic(pj, pj_dt);
end

if (strcmp(type,'DP1'))
    aibar = attr.ai;
    ai = Ai*aibar;

    ajbar = attr.aj;
    aj = Aj*ajbar;
    
    results.gamma = - ajbar'*( Aj'*Ai*tensor(omic_i_bar)*tensor(omic_i_bar) ...
                            +  tensor(omic_j_bar)*tensor(omic_j_bar)*Aj'*Ai) * aibar ...
                    + 2*omic_j_bar'*tensor(ajbar)*Aj'*Ai*tensor(aibar)*omic_i_bar ...
                    + ftdtdt_v;
    
    results.phi = ai'*aj - ft_v;
    
    results.phi_ri = zeros(1,3);
    results.phi_rj = zeros(1,3);
    results.phi_omici = -ajbar'*Aj'*Ai*tensor(aibar);
    results.phi_omicj = -aibar'*Ai'*Aj*tensor(ajbar);

    % remove fields of Phi wrt rj and omic_j when j=0, ground
    if (j == 0)
        fields = {'phi_rj', 'phi_omicj'};
        results = rmfield(results, fields);
    end
end

if (strcmp(type,'DP2'))
    aibar = attr.ai;
    sPi = attr.sPi;
    sQj = attr.sQj;
    
    dij = rj + Aj*sQj - (ri + Ai*sPi);

    results.phi = aibar'*Ai'*dij - ft_v;
    
    % TODO: change omic to omic bar
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
        results.gamma = c'*( Ai*tensor(omic_i_bar)*tensor(omic_i_bar)*sPi ...
                            -Aj*tensor(omic_j_bar)*tensor(omic_j_bar)*sQj)...
                        + ftdtdt_v;
        
        results.phi_ri = -c';
        results.phi_rj =  c';
        results.phi_omici =  c'*Ai*tensor(sPi);
        results.phi_omicj = -c'*Aj*tensor(sQj);
    else
        % body j is the ground
        sPi = attr.sPi;
        c = attr.c;
        dij = rj - (ri + Ai*sPi);
        results.phi = c'*dij - ft_v;
        results.gamma = c'*Ai*tensor(omic_i_bar)*tensor(omic_i_bar)*sPi + ftdtdt_v;
        results.phi_ri = -c';
        results.phi_omici = c'*Ai*tensor(sPi);
        % remove field of dPhi wrt rj and pj
        fields = {'phi_rj', 'phi_omicj'};
        results = rmfield(results, fields);
    end
end