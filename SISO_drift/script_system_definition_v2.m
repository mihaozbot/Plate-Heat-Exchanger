
%Static parameters 
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

M.F_c = @(V_mcv) M.k_v1*(atan(M.k_v2*(V_mcv-12)+M.k_v3)*1/pi+1/2);
M.gamma = @(V_mcv) (1+M.k_c.*(1./M.F_c(V_mcv)).^M.m)./(1+M.k_c.*((1./M.F_c(V_mcv)).^M.m+(1./M.F_p).^M.m));
M.T_sp_static = @(V_mcv) M.gamma(V_mcv).*M.T_ep + (1-M.gamma(V_mcv)).*M.T_ec;

%Dynamic parameters 
M.k_tau = [55,-0.5]; %[5.5,-0.05]; %5,0.01
M.p = 160;
M.rt = 2;
M.d = @(k,V_mcv) M.rt*sin(k*(2*pi)/M.p);

M.ts = 2;
M.du = 0.01;
M.K = @(V_mcv) (M.T_sp_static(V_mcv)-M.T_sp_static(V_mcv-M.du))./M.du;

M.n0 = 0.04;
M.N = @(w) M.n0*M.K(w)*randn(length(w),1);

