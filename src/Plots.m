close all;
clc;
%% Different Plots
% Don't plot (0) - Plot with the relevent size: (1,2,3,4,5)
opt.plotNeuronVoltage = 0;%nn   %1% Single Neuron voltage, Glutamate, Frequncy and applied current
opt.plotSpikeRaster   = 0;%r    %3% Voltage raster plot
opt.plotIappMAP       = 0;%r    %5% Applied current raster plot
opt.plotCalIP3        = 1;%aaa  %7% Calcium and IP3
opt.plotSR            = 0;%nn   %10% DSE, eSP, BoF, Gli_local, and 2AG
opt.plotAccuracy      = 1;%r    %13% Accuracy
opt.plotIneuroAstro   = 0;%r    %14% I_neuro-astro (J_omegaF)
opt.plotI_SR          = 0;%r    %15% I Self-Repairing
opt.Gli_global        = 1;%r    %16% Gli wholce-cell

%% Plot's Settings
% selects a specific duration for plot - Zero means total duration
opt.Time = 0; %[2.25 2.6];
% aa = 14;
% opt.numofAstro = [2,aa; 4,aa; 6,aa; 8,aa; 9,aa-1; 10,aa; 11,aa+1; 12,aa; 14,aa; 16,aa; 18,aa; 20,aa; 22,aa;];
opt.numofAstro = [2,8];

% nn = 21; 
% opt.numofNeuro = [25,nn+4; 30,nn+3; 35,nn+2; 40,nn+1; 45,nn; 50,nn-1; 55,nn-2; 60,nn; 65,nn; 70,nn;];
opt.numofNeuro = [62,23];%45,13 %62, 22

% Plot 1 settings - Neuron voltage options
opt.voltageFrequencyBandwidth   = 500;    %Bandwidth samples (Frequency window)
opt.voltageFrequencyShiftShift  = 10;     %Bandwidth Shifted Each Sample (Shift frequency window)
opt.voltageFrequencySmoother    = 0.01;   %Smoother of frequency plot

% Plot 2 settings - Mean voltage options
opt.meanNeuronsVoltageImage = 1;      %Number of Image
opt.meanNeuronsVoltageNoise = 1;      %Bolean

% Plot 3 settings - Voltage raster
opt.colrs3 = [1 0 0; 1 1 1; 0 0 0];
opt.locs3 = [-80, -72, 30];
opt.limits3 = [-80, +30];

% Plot 4 settings - Omega
opt.limits4 = 0; 
opt.colrs4 = [255, 255, 255;
             29, 67, 80;
             243, 144, 100;
             179, 65, 59 ]/255; 
opt.locs4 = [0, 0.68, 0.72 ,2.6];

% Plot 5 settings - I applied
opt.colrs5   = [1 1 1; 0.5 0.5 0.5; 0 0 0];
opt.locs5    = [0, 7, 10];
opt.limits5  = 0;

% Plot 6 settings - Calcium Map and mean of that
opt.limits6 = [params.ca_0, 0.9];
opt.colrs6 = [255, 255, 255;
             29, 67, 80;
             243, 144, 100;
             179, 65, 59 ]/255;
opt.locs6 = [0, 0.1,0.7, 1];

% Plot 12 settings - I_astro_neoro
opt.colrs12  = [1 1 1; 0.2 0.2 0.2];
opt.locs12   = [0, 1];
opt.limits12 = 0;

% Plot 14 settings - I_neuro_astro
opt.colrs14   = [1 1 1; 0.2 0.2 0.2];
opt.locs14    = [0, 1];
opt.limits14  = 0;

% Plot 15 settings - Isr
opt.colrs15   = [1 1 1; 0.2 0.2 0.2];
opt.locs15    = [0, 1];
opt.limits15  = 0;

% MAP color
opt.MAPcolor1 = [0.5, 0.8, 0.9]; %[Red, Green, Blue]
opt.MAPcolor2 = [1, 1, 1]; %[Blue, Red, Green]

opt.Opacity   = 0.1;

%% Call plot function
plot_figures(model, params, opt);
