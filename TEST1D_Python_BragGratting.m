% 用来Benchmark代码的例子：https://github.com/edmundsj/rcwa
% 这是一个多层介质，理论上不需要RCWA方法。
n1=3.5;
n2=1.45;

WL0=1300;
WLMat=linspace(600,2200,601);

eps_layer_1=Material('Layer1',[n1^2,1]);
eps_layer_2=Material('Layer2',[n2^2,1]);

d1=WL0/4/n1/1000;
d2=WL0/4/n2/1000;

period=1;
epssup=1;epssdn=1;
num_xy=21;

num_har=3;
%%
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(WLMat,[0,0],[1,0]);
Dev = Device([period,period],[num_xy,1],[num_har,1]);
for l=1:5
AddLayer(Dev,eps_layer_1,d1,1);
AddLayer(Dev,eps_layer_2,d2,1);
end

% Run Simulations
RCWARun(Simul,S,Dev)
PlotRT(Simul)


%% 在此尝试人为定义Grating
Simul_TZH = RCWA([epssup,1],[epssdn,1],ShowProcess);
DevTZH=Device([period,period],[num_xy,1],[num_har,1]);
ER=zeros(num_xy,1,10);
UR=ones(num_xy,1,10);
d=zeros(10,1);
for l=1:5
ER(:,1,2*l-1)=n1^2;
ER(:,1,2*l)=n2^2;
d(2*l-1,1)=d1;
d(2*l,1)=d2;
end
Simul_TZH.WhetherBuildLayer=0;
AddMaterial_Mannual(DevTZH,ER,UR,d);
%%
RCWARun(Simul_TZH,S,DevTZH)
PlotRT(Simul_TZH)

saveas(gcf,'./figures/TEST1D_Python_BragGratting.png');