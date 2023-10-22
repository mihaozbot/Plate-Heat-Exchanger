
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

%DC gain model- without derivative
M.F_c = @(V_mcv) M.k_v1*(atan(M.k_v2*(V_mcv-12)+M.k_v3)*1/pi+1/2);
M.gamma = @(V_mcv) (1+M.k_c.*(1./M.F_c(V_mcv)).^M.m)./(1+M.k_c.*((1./M.F_c(V_mcv)).^M.m+(1./M.F_p).^M.m));
M.T_sp_static = @(V_mcv) M.gamma(V_mcv).*M.T_ep + (1-M.gamma(V_mcv)).*M.T_ec;

%Dynamic parameters 
M.k_tau = [55,-0.5]; %
M.k_tau_up = [55,-0.5]; %[5.5,-0.05]; %5,0.01
%M.k_tau_down = [50,0]; %za ts = 0.1 [7,0]; %5,0.01
M.k_tau_down = [55,-0.5];
M.tau_up = @(T_sp) M.k_tau_up(1) + M.k_tau_up(2)*T_sp^1;
M.tau_down = @(T_sp) M.k_tau_down(1) + M.k_tau_down(2)*T_sp^1;
M.tau = @(T_sp,V_mcv) (M.T_sp_static(V_mcv)>=T_sp).*(M.tau_up(T_sp)) + ...
    (M.T_sp_static(V_mcv)<T_sp).*(M.tau_down(T_sp));

%Rezervoar water disturbance
M.p = 160;
M.rt = 2;
%M.d = @(k,V_mcv) 0.02*M.T_sp_static(V_mcv)*sin(k*(2*pi)/M.p);
M.d = @(k,V_mcv) M.rt*sin(k*(2*pi)/M.p);

%Whole model
M.dT_sp = @(t,k,y,V_mcv) (-y + M.gamma(V_mcv).*M.T_ep +...
    + (1-M.gamma(V_mcv)).*(M.T_ec + M.d(k,V_mcv)))./M.tau(y,V_mcv);

%Sample time
M.ts = 2;

%M.Y = @(u,yk1,k) ode23(@(t,y) M.dT_sp(t, k, yk1, u), [0,M.ts], yk1).y(end);
M.Y = @(u,yk1,k) ode1(@(t,y) M.dT_sp(t, k, yk1, u), M.ts, yk1);

%M.Y = @(u,yk1) yk1 + M.ts*M.dT_sp(0,yk1,u);
%y(k) = M.Y(u(k),y(k-1))
M.du = 0.01;
M.K = @(V_mcv) (M.T_sp_static(V_mcv)-M.T_sp_static(V_mcv-M.du))./M.du;

M.n0 = 0.04;
M.N = @(w) M.n0*M.K(w)*randn(length(w),1);



