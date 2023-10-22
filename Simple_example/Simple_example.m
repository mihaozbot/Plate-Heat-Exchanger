clc; clear all; close all;

script_system_definition

u = repelem(4:1:20,300);% Input hot water valve current [A] [4,20]
y = 10*ones(1,3); % Output water temperature [°C]
z = [u(1:3)',y',90*ones(3,1)]; %All signals

k_shift_1 = 2000;
k_shift_2 = 4000;
for k = 3:1:length(u)

    %Shift in the system operation
    if k == k_shift_1
        M.F_p = 0.8; %We open the cold water valve
        script_system_definition_shift
    elseif k == k_shift_2
        M.F_p = 0.6; %We close the cold water valve
        script_system_definition_shift
    end
    
    %Model evaluation
    d(k) = M.T_ec + M.rt*sin(k*(2*pi)/M.p); %Reservoir hot water temperature [°C]
    y(k) = PHE(u(k-1), y(k-1), d(k-1), M); % Output water temperature [°C]
    z(k,:) = [u(k), y(k) + M.N(u(k-1)), M.T_ec + M.d(k, u(k-1))]; %All signals

end

figure; hold on;
plot(z(:,1))
plot(z(:,2))
plot(z(:,3))
xlabel('Time step [k]')
title('Plate Heat Exchanger theoretical model with drift')
legend('Reservoir hot water temperature [°C]','Output water temperature [°C]',...
    'Input hot water valve current [A]','location','best')


