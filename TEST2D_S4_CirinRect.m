%  为了保证计算结果的准确性，和一些文献的结果进行对比
% 这里和S4的结果进行比对: Fig 5 in following references
% 1. Liu, V. & Fan, S. S4 : A free electromagnetic solver for layered periodic structures.
% Computer Physics Communications 183, 2233–2244 (2012).

eps_layer=12;
radius=0.2;
width=1;
d=0.5;

% 注意原文章的横坐标的归一化方式！
fa=1/1000;
fswep=linspace(0.5,0.55,301)*fa;
lambda=1./fswep;
epssup=1;epssdn=1;
num_xy=521;
numz=1;
num_har=7;

mid_layer=Material('TZH',[eps_layer,1]);
Air = Material('test',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[0,0],[1,0]);
Dev = Device([width,width],[num_xy,num_xy],[num_har,num_har]);
AddLayer(Dev,mid_layer,d,1);
AddPattern(Dev,'Cylinder',[width/2,width/2],radius,[1],Air);
%% Run Simulations
RCWARun(Simul,S,Dev)
% PlotRT(Simul)
%% 
figure()
plot(fswep*1000,Simul.T/100,'b','linewidth',2);
hold on
plot(fswep*1000,Simul.R/100,'r','linewidth',2);
legend('Transmission','Reflection','location','best');
xlim([0.5 0.55]);
xlabel('Frequency (2\pi c/a)');
ylabel('Transmission and Reflection');
saveas(gcf,'./figures/TEST2D_S4_CirinRect.png');