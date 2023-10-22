clc; clear; close all;

x = 0:0.1:20;

ka1 = 1;
y_atan = (atan(ka1*(x-10))*1/3+1/2);

X5 = [ones(length(x),1), x',x'.^2,x'.^3,x'.^4,x'.^5];
k5 = (X5'*X5)\(X5'*y_atan');
y5 = k5(1)+k5(2)*x+k5(3)*x.^2+k5(4)*x.^3+k5(5)*x.^4+k5(6)*x.^5;

X2 = [ones(length(x),1), x',x'.^2];
k2 = (X2'*X2)\(X2'*y_atan');
y2 = k2(1)+k2(2)*x+k2(3)*x.^2;

X3 = [ones(length(x),1), x',x'.^2,x'.^3];
k3 = (X3'*X3)\(X3'*y_atan');
y3 = k3(1)+k3(2)*x+k3(3)*x.^2+k3(4)*x.^3;


figure; hold on;
plot(x,y_atan)
plot(x,y5)
plot(x,y3)
plot(x,y2)


