clc; clear all; close all;

load data
fuzzy_model

%Phi = [y,u,1]
M.mehke_y = @(y,u) M.mehke_theta*[y,u,1]';
M.mY = @(y,u) sum((M.mehke_mnozice(y)*M.mehke_y(y,u))/sum(M.mehke_mnozice(y)));
%M.Y =  
figure
title('Mehke množice')
plot(4:0.01:59, M.mehke_mnozice(4:0.01:59))
xlim([4,59])


u = 5:1:20;
k_h = 300;
u = repelem(u,1,k_h);
k_fin = length(u);
y(1:2) = 20;
ts = 4;
t(1:2) = 0:ts:ts;
for k = 2:1:k_fin
    
    t(k) = k*ts;
    y(k) =  M.mY(y(k-1),u(k));

end

figure
plot(t,y)
title('Step input response verification')


figure
idc = k_h:k_h:k_fin;
plot(sc_Vmcv,sc_Tsp); hold on;
plot(u(idc),y(idc));
title('Statical characteristic verification')

