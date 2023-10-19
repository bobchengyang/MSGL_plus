clear;clc;close all;

load('Appliance_ON_OFF.mat');

figure(1);

for i=1:15
    subplot(15,1,i);plot(Appl_ON_OFF(i,:));
end

figure(2);
subplot(2,1,1);plot(Appl_ON_OFF(6,:));
subplot(2,1,2);plot(Appl_ON_OFF(15,:));