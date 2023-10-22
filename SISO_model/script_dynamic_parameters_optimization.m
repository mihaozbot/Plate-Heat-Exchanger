clc; clear all; close all;
set(0,'defaultTextInterpreter','latex')

script_system_definition_v2
script_system_definition

%load par T_ep T_ec m k_c F_p k_v1 k_v2 k_v3
%  T_ep = 0;%0; 0.0015
%  T_ec  = 90;%90;
%  m  = 1.93;%1.86; 1.8572
%  k_c = 0.65;%0.79; 0.7869
%  F_p = 0.53;%0.56; 0.5607
%  k_v1 = 1.04;%1.1; 1.1028
%  k_v2 = 0.23; %0.24; 0.2416

%Simulation
du = 2;
umin = 4; 
umax = 20;
khold = 200;
u_static = [umin:du:umax,(umax-du):-du:umin];
U = repelem(u_static,1,khold);
kfin = length(U);
tfin = kfin*M.ts;
time = M.ts:M.ts:tfin;
Tsp = zeros(kfin,1);
Tsp(1) = 10;
Tsp_test = zeros(kfin,1);
Tsp_test(1) = 10;
tspan = [0, M.ts];

% k_tau = [5.5,-0.1];
% tau = @(T_sp) k_tau(1) + k_tau(2)*T_sp^1;
% F_c = @(V_mcv) k_v1*(atan(k_v2*(V_mcv-10)+k_v3)*1/pi+1/2);
% gamma = @(u) (1+k_c*(1/F_c(u))^m)/(1+k_c*((1/F_c(u))^m+(1/F_p)^m));
% dydt = @(t,y,u) (-y + gamma(u)*T_ep + (1-gamma(u))*T_ec)/tau(y);

simy_ode45 = Tsp;
simy_ode1 = Tsp;
simy_fun_ode1 = Tsp;
for k = 2:1:kfin
    
    %tspan = [(k-1)*ts, k*ts];
    %simy_ode45(k) = ode45(@(t,y) M.dT_sp(t,k,simy_ode45(k-1), U(k)),tspan,simy_ode45(k-1)).y(end);
    simy_ode1(k) = ode1(@(t,y)M.dT_sp(t,k,simy_ode1(k-1), U(k)),tspan,simy_ode1(k-1)).y(end);
    %Tsp(k) = M.Y(Tsp(k-1),U(k));
    %Tsp_test(k) = M.Y(U(k),Tsp_test(k-1));
    d(k) = M.T_ec + M.rt*sin(k*(2*pi)/M.p);
    simy_fun_ode1(k) = PHE(U(k),simy_fun_ode1(k-1),d(k),M);
end


% figure
% plot(time,Tsp,'b')
% ylabel("$Output T_{sp} [$^\circ$C$]$")
% xlabel("Čas [s]")
% ax = gca;
% ax.Toolbar.Visible = 'off';
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Simulacija modela');
% set(h, 'fontsize',16,'FontWeight','Normal')
% exportgraphics(gca, 'izmenjevalnik_simulacija.pdf','ContentType','vector');
% 
load data
Ts_static = Tsp(khold:khold:end);
% 
% figure; hold on;
% plot(sc_Vmcv,sc_Tsp,'b')
% plot(u_static,Ts_static,'r')
% legend('System data','Model')
% ylabel("T_{sp}[°C]")
% xlabel("V_{mdv}[mA]")
% title('Statical characteristic of the plant')

% figure;
% plot(sc_Vmcv,F_c)
% xlabel("V_{mdv}[mA]")
% ylabel("F_c[%]")
% ax = gca;
% ax.Toolbar.Visible = 'off';
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Karakteristika vhodnega ventila');
% set(h, 'fontsize',16,'FontWeight','Normal')

%exportgraphics(gca, 'izmenjevalnik_vhodni_ventil.pdf','ContentType','vector');

figure;
subplot(2,1,1)
%plot(time,simy_ode45,'b'); hold on;
hold on;
plot(time,simy_ode1,'r');
plot(time,simy_fun_ode1,'b--');
ylabel("Izhodni signal $T_{sp}[^\circ$C$]$")
xlabel("Čas [s]")
%xlim([0,length(U)/10])
ylim([10,50])
ax = gca;
ax.Toolbar.Visible = 'off';
set(ax,'fontname','Times', 'FontSize', 12);
h = title('Simulacija modela');
set(h, 'fontsize',16,'FontWeight','Normal')
%exportgraphics(gca, 'izmenjevalnik_simulacija.pdf','ContentType','vector');

% subplot(2,1,2)
% plot(sc_Vmcv,F_c,'b')
% xlabel('$V_{mdv}[mA]$')
% ylabel('$F_c[\%]$')
% ax = gca;
% ax.Toolbar.Visible = 'off';
% set(ax,'fontname','Times', 'FontSize', 12);
% h = title('Karakteristika vhodnega ventila');
% set(h, 'fontsize',16,'FontWeight','Normal')
%exportgraphics(gca, 'izmenjevalnik_vhodni_ventil.pdf','ContentType','vector');
