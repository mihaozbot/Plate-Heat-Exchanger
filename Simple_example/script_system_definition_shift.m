
%When parameters are changed we must reset the functions, this is used to generate the heteroskedastic noise
M.F_c = @(V_mcv) M.k_v1*(atan(M.k_v2*(V_mcv-12)+M.k_v3)*1/pi+1/2);
M.gamma = @(V_mcv) (1+M.k_c.*(1./M.F_c(V_mcv)).^M.m)./(1+M.k_c.*((1./M.F_c(V_mcv)).^M.m+(1./M.F_p).^M.m));
M.T_sp_static = @(V_mcv) M.gamma(V_mcv).*M.T_ep + (1-M.gamma(V_mcv)).*M.T_ec;
M.d = @(k,V_mcv) M.rt*sin(k*(2*pi)/M.p);
M.K = @(V_mcv) (M.T_sp_static(V_mcv)-M.T_sp_static(V_mcv-0.01))./0.01;
M.N = @(w) M.n0*M.K(w)*randn(length(w),1);
