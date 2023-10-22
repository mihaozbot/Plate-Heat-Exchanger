clear all; close all; clc;
set(0,'defaultTextInterpreter','latex')

global sc_Tsp sc_Vmcv dc_K dc_Tsp 
global static_char_value dc_gain_value
global T_ep_min T_ep_max m_min T_ec_min T_ec_max k_c_min F_min F_max

%Load model
script_system_definition

%Initial parameters
T_ep_0 = 0;
T_ec_0 = 70;
m_0 = 2;
k_c_0 = 1;
F_p_0 = 1;
k_v1_0 = 1.1;
k_v2_0 = 0.25;
k_v3_0 = 0;
k_v4_0 = 0;
par_0 = [T_ep_0,T_ec_0,m_0,k_c_0,F_p_0,k_v1_0,k_v2_0,k_v3_0,k_v4_0];

%Constraints
T_ep_min = 0;
T_ep_max = 30;
m_min = 0.1;
T_ec_min = 40;
T_ec_max = 90;
k_c_min = 0.1;
F_min = 0;
F_max = 1;
% T_ep = 0; 0.0015
% T_ec  = 90;
% m  = 1.86; 1.8572
% k_c = 0.79; 0.7869
% F_p = 0.56; 0.5607
% k_v1 = 1.1; 1.1028
% k_v2 = 0.24; 0.2412

%Load static characteristic and dc gain
load data;

%Optimization error focus
static_char_value = 1;
dc_gain_value = 1;

%fminsearch
options = optimset('maxIter', 10000,'MaxFunEvals', 100000);
[par,fval,exitflag,e] = fminsearch(@func, par_0, options);

T_ep = par(1);
T_ec = par(2);
m = par(3);
k_c = par(4);
F_p = par(5);
k_v1 = par(6);
k_v2 = par(7);
k_v3 = par(8);
k_v4 = par(9);

%DC gain model- without derivative
gamma = @(F_c) (1+k_c*(1./F_c).^m)./(1+k_c.*((1./F_c).^m+(1./F_p).^m));
T_sp = @(F_c) gamma(F_c)*T_ep + (1-gamma(F_c))*T_ec;
%F_c = k_v1.*sc_Vmcv + k_v2.*sc_Vmcv.^2+ k_v3.*sc_Vmcv.^3+ k_v4.*sc_Vmcv.^4;
F_c = k_v1*(atan(k_v2*(sc_Vmcv-10)+k_v3)*1/pi+1/2);
%k_v1.*sc_Vmcv + k_v2.*sc_Vmcv.^2+ k_v3.*sc_Vmcv.^3;
%k_v1*sc_Vmcv;
%k_v1.*sc_Vmcv + k_v2.*sc_Vmcv.^2;
y = T_sp(F_c);
K = (T_sp(F_c(2:end))-T_sp(F_c(1:end-1)))./(sc_Vmcv(2:end)-sc_Vmcv(1:end-1));

% figure;
% plot(sc_Vmcv,F_c)
% xlabel("V_{mdv}[mA]")
% ylabel("F_c[%]")
% ax = gca;
% ax.Toolbar.Visible = 'off';
% 
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Karakteristika vhodnega ventila');
% set(h, 'fontsize',12)
% exportgraphics(gca, 'izmenjevalnik_vhodni_ventil.pdf','ContentType','vector');

% f2 = figure; hold on;
% plot(sc_Vmcv, sc_Tsp, 'r')
% plot(sc_Vmcv, y, 'b')
% ylabel("T_{sp}[\circ C]")
% xlabel("V_{mdv}[mA]")
% title('Statical characteristic of the plant')
% legend('System data','Model')
% ax = gca;
% ax.Toolbar.Visible = 'off';
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Statična karakteristika');
% set(h, 'fontsize',16,'FontWeight','Normal')
% h = legend('Izmerjena statična karakteristika','Statična karakteristika modela','Location','Southeast');
% set(h, 'fontsize',12)
% exportgraphics(gca, 'izmenjevalnik_staticna_karakteristika.pdf','ContentType','vector');
% 
% figure; hold on;
% plot(dc_Tsp, dc_K,'r')
% plot(dc_Tsp, K,'b')
% ylabel('Ojačenje procesa')
% xlabel('$T_{sp}[\circC]')
% %title('Relation between process gain and output temperature')
% ax = gca;
% ax.Toolbar.Visible = 'off';
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Enosmerno ojačenje');
% set(h, 'fontsize',16,'FontWeight','Normal')
% h = legend('Podatki','Model','Location','northeast');
% set(h, 'fontsize',12)
% exportgraphics(gca, 'izmenjevalnik_ojacenje.pdf','ContentType','vector');

figure;
subplot(2,1,1); hold on;
plot(sc_Vmcv, y,'b')
plot(sc_Vmcv, sc_Tsp,'r')

ylabel('$T_{sp} [^{\circ}$C$]$')
xlabel('$V_{mdv}$[mA]')
ax = gca;
ax.Toolbar.Visible = 'off';
set(ax,'fontname','Times', 'FontSize', 12);
h = title('Statična karakteristika');
set(h, 'fontsize',16,'FontWeight','Normal')
h = legend('Statična karakteristika modela','Izmerjena statična karakteristika','Location','Southeast');
set(h, 'fontsize',12)

subplot(2,1,2); hold on;
plot(dc_Tsp, K,'b')
plot(dc_Tsp, dc_K,'r')

ylabel('Ojačenje procesa')
xlabel('$T_{sp} [^{\circ}$C$]$')
xlim([13,50])
ax = gca;
ax.Toolbar.Visible = 'off';
set(ax,'fontname','Times', 'FontSize', 12);
h = title('Razmerje med ojačenjem procesa in izhodno temperaturo');
set(h, 'fontsize',16,'FontWeight','Normal')
h = legend('Ojačenje modela','Izmerjeno ojačenje ','Location','southwest');
set(h, 'fontsize',12)
exportgraphics(gcf, 'izmenjevalnik_staticna_in_ojacenje.pdf','ContentType','vector');

save par T_ep T_ec m k_c F_p k_v1 k_v2 k_v3

%Load model
script_system_definition; M



function err = func(par)

global sc_Tsp sc_Vmcv dc_K dc_Tsp 
global static_char_value dc_gain_value
global T_ep_min T_ep_max m_min T_ec_min T_ec_max k_c_min F_min F_max

T_ep = par(1);
T_ec = par(2);
m = par(3);
k_c = par(4);
F_p = par(5);
k_v1 = par(6);
k_v2 = par(7);
k_v3 = par(8);
k_v4 = par(9);

%DC gain model- without derivative
gamma = @(F_c) (1+k_c*(1./F_c).^m)./(1+k_c.*((1./F_c).^m+(1./F_p).^m));
T_sp = @(F_c) gamma(F_c)*T_ep + (1-gamma(F_c))*T_ec;
%F_c = k_v1.*sc_Vmcv + k_v2.*sc_Vmcv.^2+ k_v3.*sc_Vmcv.^3+ k_v4.*sc_Vmcv.^4;
F_c = k_v1*(atan(k_v2*(sc_Vmcv-10)+k_v3)*1/pi+1/2);

% Static characteristic
err_static = sc_Tsp - T_sp(F_c);
err_static = sum(err_static.^2);

%DC gain
err_dc_gain = dc_K - (T_sp(F_c(2:end))-T_sp(F_c(1:end-1)))./(sc_Vmcv(2:end)-sc_Vmcv(1:end-1));
err_dc_gain = sum(err_dc_gain.^2);

err = static_char_value*err_static +  dc_gain_value*err_dc_gain;

%Constraits
cons = (par(1) >= par(2)) ||...
    ((T_ep < T_ep_min)  || (T_ep > T_ep_max)) ||...
    ((T_ec < T_ec_min)  || (T_ec > T_ec_max))||...
    (m < m_min)||...
    (k_c < k_c_min)||...
    ((F_p < F_min) || (F_p > F_max))||...
    (any(F_c < F_min) || any(F_c > F_max));

if cons
    err = 1e100;
end

if any(gamma(F_c)> 1) || any(gamma(F_c)<0)
    disp('error gamma')
end
end
