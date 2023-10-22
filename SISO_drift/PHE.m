function y = PHE(u1,y,d,M)

    F_c = M.k_v1*(atan(M.k_v2*(u1-12)+M.k_v3)*1/pi+1/2);
    gamma = (1+M.k_c*(1/F_c)^M.m)/(1+M.k_c*((1/F_c)^M.m+(1/M.F_p)^M.m));
    tau = M.k_tau(1) + M.k_tau(2)*y^1;
    y = y + M.ts*(-y + gamma.*M.T_ep + (1-gamma).*d)/tau;

end