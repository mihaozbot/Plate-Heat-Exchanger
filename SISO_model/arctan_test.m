x = -10:0.01:10; 
ytanh = (tanh(x)+1)/2;

yarctan = (1/pi)*atan(x)+1/2;

figure
plot(x,yarctan); hold on;
plot(x,ytanh);
