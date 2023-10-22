clc; clear all; close all;
set(0,'defaultTextInterpreter','latex')

PHE_MISO_model_parameters

%Simulation
du = 1;
umin = 4; 
umax = 20;
khold = 100;
u_static = [umin:du:umax,(umax-du):-du:umin];
[U1,U2] = meshgrid(u_static,u_static);
u1 = repelem(U1(:)',1,khold);
u2 = repelem(U2(:)',1,khold);

kfin = length(u1);
tfin = kfin*M.ts;
time = M.ts:M.ts:tfin;
Tsp = zeros(kfin,1);
Tsp(1) = 10;
Tsp_test = zeros(kfin,1);
Tsp_test(1) = 10;
tspan = [0, M.ts];

simy_ode45 = Tsp;
simy_ode1 = Tsp;
simy_fun_ode1 = Tsp;
for k = 2:1:kfin
    
    %OLD CODE
    %tspan = [(k-1)*ts, k*ts];
    %simy_ode45(k) = ode45(@(t,y) M.dT_sp(t,k,simy_ode45(k-1), U(k)),tspan,simy_ode45(k-1)).y(end);
    %simy_ode1(k) = ode1(@(t,y)M.dT_sp(t,k,simy_ode1(k-1), U(k)),tspan,simy_ode1(k-1)).y(end);
    %Tsp(k) = M.Y(Tsp(k-1),U(k));
    %Tsp_test(k) = M.Y(U(k),Tsp_test(k-1));
    %d(k) = M.T_ec + M.rt*sin(k*(2*pi)/M.p);

    simy_fun_ode1(k) = PHE_MISO(u1(k),u2(k),simy_fun_ode1(k-1),M.T_ec ,M);
    
end


Z = reshape(simy_fun_ode1(khold-1:khold:end),[],size(U1,2));
figure(1);
subplot(3,3,7)
s = mesh(U1,U2,Z);
s.FaceColor ='none';
s.FaceAlpha = 1;
s.EdgeColor = [0,0,0];
xlim("tight");
ylim("tight");
zlim("tight");
view(-45,45)
xlabel('Input $u_1$')
ylabel('Input $u_2$')
zlabel('Output $y$')
exportgraphics(gca, 'PHE_MISO_3D.pdf','ContentType','vector');

figure(1);
subplot(3,3,8)
levels= 0:5:80;
contour3(U1,U2,Z,levels)
view(-45,45)
xlim("tight");
ylim("tight");
zlim("tight");

figure(1);
subplot(3,3,9)
surf(U1,U2,Z)
view(-45,45)
xlim("tight");
ylim("tight");
zlim("tight");
xlabel('Input $u_1$')
ylabel('Input $u_2$')
zlabel('Output $y$')
% exportgraphics(gca, 'PHE_MISO_3D.pdf','ContentType','vector');

figure(1);
subplot(16,1,1:9)
%plot(time,simy_ode45,'b'); hold on;
hold on;
%plot(time,simy_ode1,'r');
plot(time,simy_fun_ode1,'b');
ylabel("Izhodni signal $T_{sp}[^\circ$C$]$")
xlabel("Čas [s]")
%xlim([0,length(U)/10])
ylim('tight')
ax = gca;
ax.Toolbar.Visible = 'off';
set(ax,'fontname','Times', 'FontSize', 12);
h = title('Simulacija modela');
set(h, 'fontsize',16,'FontWeight','Normal')
%exportgraphics(gca, 'izmenjevalnik_simulacija.pdf','ContentType','vector');
