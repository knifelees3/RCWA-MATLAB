% 为了保证计算结果的准确性，和一些文献的结果进行对比
% 这里和Python的结果进行对比：来自github仓库，https://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis
% 用来对比的源Python代码地址：https://github.com/zhaonat/Rigorous-Coupled-Wave-Analysis/blob/master/RCWA_1D_examples/1D_Grating_Gaylord_TE.py


eps_layer=3.48^2;
width=0.3*0.7;
period=0.7;
d=0.46;
lambda=linspace(500,2300,401);
epssup=1;epssdn=1;
num_xy=1021;
numz=1;
num_har=21;
mid_layer=Material('TZH',[eps_layer,1]);
%% 
Air = Material('test',[1,1]);
ShowProcess=1;
Simul = RCWA([epssup,1],[epssdn,1],ShowProcess);
S = Source(lambda,[0,0],[1,0]);
Dev = Device([period,period*8],[num_xy,1],[num_har,1]);
AddLayer(Dev,Air,d,numz);
AddPattern(Dev,'Rectangle',[period/2,period*8/2],[width width],1,mid_layer);
% Run Simulations
RCWARun(Simul,S,Dev)
PlotRT(Simul)

saveas(gcf,'./figures/TEST1D_Python_1DGrating.png');
