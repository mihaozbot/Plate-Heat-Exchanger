clc; clear all; close all;

%% Paraameters
u_min = 0; %0.6
u_max = 0.1; %2.2
u_delta = (u_max - u_min)/12;
u = u_min:u_delta:u_max;
k_hold = 1000;
u = repelem(u',k_hold,1);
    
ts = 2;
k_fin = length(u);
n_meas = 2;
x = zeros(k_fin, n_meas);
t = zeros(k_fin,1);
t_delta = zeros(k_fin,1);

datetime.setDefaultFormats('default','yyyy_MM_dd_hh_mm')
datum = datetime;
file_name = ['measurement_steps_',datestr(datum,'yyyy_mm_dd_hh_MM'),'.mat'];
file_name_all = ['measurement_steps_all_',datestr(datum,'yyyy_mm_dd_hh_MM'),'.mat'];
save(file_name,'t','x'); % Write to MAT file

figure(1); figure(2); figure(3); figure(4); pause(0.001);
figure(1); title('Both output sensors signals'); xlabel('Sample [k]'); ylabel('Sensors signal');hold on;
figure(2); title('First output sensor signal - output water temp.'); xlabel('Sample [k]');ylabel('Sensor 1 signal');hold on;
figure(3); title('Second output sensor signal - hot water temp.'); xlabel('Sample [k]');ylabel('Sensor 2 signal');hold on;
figure(4); title('Input signal - hot water valve amperage'); xlabel('Sample [k]');ylabel('Input signal'); hold on;
figure(5); title('Sampling time'); xlabel('Sample [k]'); ylabel('Sampling time'); hold on;

%% Initialization of communication
dev = PK_Connect(100);

%Timer start
tic

%% MAIN LOOP
for k  = 4:1:k_fin
    
    %Sampling pause
    t_pause = 0;
    while t_pause < ts
        t_pause = toc;
    end
    
    %Take measurement
    t_delta(k) = toc;
    x(k,:) = measure(dev,u(k));
    t(k) = t(k-1) + t_delta(k);
    
    %Timer start
    tic
    
    %Shranjevanje rezultatov
    save(file_name,'t','x','-append'); % Write to MAT file
    
    if (k>10) && (mod(k,ceil(1/ts)) == 0)
        figure(1)
        plot(t(k-1:k),x(k-1:k,1),'b');
        plot(t(k-1:k),x(k-1:k,2),'r');
        figure(2);plot(t(k-1:k),x(k-1:k,1),'b');
        figure(3);plot(t(k-1:k),x(k-1:k,2),'r');
        figure(4);plot(t(k-1:k),u(k-1:k),'b')
        figure(5);plot(t(k-1:k),t_delta(k-1:k),'b')
        pause(0.001)
    end
    
end

save(file_name_all)

%% Disconect communication
[inputs, enc] = PK_DoIO(dev, [0,0,0,0]);
PK_Disconnect(dev);

