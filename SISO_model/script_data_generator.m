clear; close all; clc
%Static characteristic
%x axis
sc_Vmcv_M = 16/27;
sc_Vmcv_0 = 4;
sc_Vmcv_raw = [1.1,2.1,3.25,4.35,5.4,6.4,7.5,8.6,9.65,10.45,12.9,15.0,19.4,23.6,27];
sc_Vmcv = sc_Vmcv_raw*sc_Vmcv_M + sc_Vmcv_0;
%y axis
sc_Tsp_M = 50/14.4;
sc_Tsp_0 = 10;
sc_Tsp_raw = [1.05,1.5,2.2,2.95,3.7,4.4,5.5,6.5,7.4,7.95,9.15,9.95,10.9,11.45,11.65];
sc_Tsp = sc_Tsp_raw*sc_Tsp_M + sc_Tsp_0;

%DC gain
%x axis
dc_Tsp_M = 50/24.55;
dc_Tsp_0 = 10;
dc_Tsp_raw = [1.8,2.6,3.75,4.9,6.2,7.45,9.45,11.2,12.6,13.9,15.75,17.0,18.65,19.6];
dc_Tsp = dc_Tsp_raw*dc_Tsp_M + dc_Tsp_0;
%y axis
dc_K_M = 7/13;
dc_K_0 = 0;
dc_K_raw = [4.9,6.6,6.6,8.0,7.55,11.2,10.4,8.8,7.0,5.4,4.05,2.45,1.4,0.85];
dc_K = dc_K_raw*dc_K_M + dc_K_0;

dc_K_test = (sc_Tsp(2:end) - sc_Tsp(1:end-1))./(sc_Vmcv(2:end) - sc_Vmcv(1:end-1));

save data sc_Vmcv sc_Tsp dc_Tsp dc_K

figure
plot(sc_Vmcv,sc_Tsp,'b','linewidth',2); hold on;
stem(sc_Vmcv,sc_Tsp,'b')
grid on
xticks(sc_Vmcv_0:1:sc_Vmcv(end))
ylabel("T_{sp}[°C]")
xlabel("V_{mdv}[mA]")
title('Statical characteristic of the plant')

figure
plot(dc_Tsp,dc_K,'b','linewidth',2); hold on;
plot(sc_Tsp(1:end-1),dc_K_test,'r')
stem(dc_Tsp,dc_K,'b')
stem(sc_Tsp(1:end-1),dc_K_test,'r')
grid on
xticks(dc_Tsp_0:2:1.1*dc_Tsp(end))
ylabel("Process gain")
xlabel("T_{sp}[°C]")
title('Relation between process gain and putput temperature')

