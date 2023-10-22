
%Static parameters 
M = load_parameters();

M.n0 = 0.04; %Noise standard deviation
M.k_tau = [55,-0.5]; %tau constants
M.ts = 4; %sampling time
M.p = 160; %hot water oscilation period
M.rt = 2; %hot water oscilation amplitude


function M = load_parameters()
    load par T_ep T_ec m k_c F_p k_v1 k_v2 k_v3
    M.T_ep = T_ep;
    M.T_ec = T_ec;
    M.m =  m;
    M.k_c = k_c;
    M.F_p = F_p;
    M.k_v1 = k_v1;
    M.k_v2 = k_v2;
    M.k_v3 = k_v3;
    clear T_ep T_ec m k_c F_p k_v1 k_v2 k_v3;
end