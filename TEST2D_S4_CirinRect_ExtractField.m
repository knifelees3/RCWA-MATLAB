% 从结果中获取电磁场
% 只选取特定的波长即可
eps_layer=12;
radius=0.2;
width=1;
d=0.5;

% 注意原文章的横坐标的归一化方式！
lambda=1000;
epssup=1;epssdn=1;
num_xy=521;
numz=1;
num_har=7;

mid_layer=Material('Mid',[eps_layer,1]);
Air = Material('Air',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[0,0],[1,0]);
Dev = Device([width,width],[num_xy,num_xy],[num_har,num_har]);
AddLayer(Dev,mid_layer,d,1);
AddPattern(Dev,'Cylinder',[width/2,width/2],radius,1,Air);

% Activate the field recorder
ConstructField(Simul);% 用于记录场
%% To obtain the field in specific plane
% Thefield grid
field=Field();
XYGird=[100 100];
ZLayer=0.1;
GetLayerField(field,XYGird,ZLayer);
RCWARun(Simul,S,Dev,field);
ShowLayerField(field);

%% To obatin the field in xyz grid
field=Field();
XYGird=[100 100];
Z_Gird=linspace(0,0.5,10);
GetGridField(field,XYGird,Z_Gird);
RCWARun(Simul,S,Dev,field);
ShowGridField(field);
