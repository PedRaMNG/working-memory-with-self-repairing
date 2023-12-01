# Working Memory(WM) with Self Repairing (SR) in a Spiking Neuron-Astrocyte Network (SNAN)

Some parts of the code are from: https://github.com/altergot/neuro-astro-network

The self-repairing capability and some modifications in the working memory model are added in this work.

This repository is the MATLAB codes for the WM with SR model, published in iScience journal.

Link to the paper: https://doi.org/10.1016/j.isci.2023.108241

# Requirements:

* MATLAB 2018 or later.
* A system with minimum 32 G of ram.

# Settings

There are 4 experiments in the paper which require a uniques set of settings to get them.

## Experiment 1 - Healthy network with SR signal

To get the results for this experiment set the following parameters in **`model_parameters.m`** file in this format:

```matlab
params.SelfRepair = 1; % activates the SR modulation
params.simPattern = 1; % set the inputs as numbers 0 to 3
params.impairmode = 0; % keep the network in healthy condition
```

In order to get the results, run `main.m` file.

In order to plot the outputs, in `Plots.m` file, set the variables you want to plot to `1` and run `Plots.m` file.

## Experiment 2 - Discrete pattern-specific damage mode

To get the results for this experiment set the following parameters in **`model_parameters.m`** file in this format:

```matlab
params.SelfRepair = 1; % activates the SR modulation
params.simPattern = 1; % set the inputs as numbers 0 to 3
params.impairmode = 3; % damages the network with discrete lines damaging pattern
```

In order to get the results, run `main.m` file.

In order to plot the outputs, in `Plots.m` file, set the variables you want to plot to `1` and run `Plots.m` file.

## Experiment 3 – Continuous pattern-specific damage mode

To get the results for this experiment set the following parameters in **`model_parameters.m`** file in this format:

```matlab
params.SelfRepair = 1; % activates the SR
params.simPattern = 2; % set the inputs as two strips
params.impairmode = 3; % damages the network with dense core damaging pattern
```

In order to get the results, run `main.m` file.

In order to plot the outputs, in `Plots.m` file, set the variables you want to plot to `1` and run `Plots.m` file.

## Experiment 4 – Analytic results for random damage mode

To get the results for this experiment set the following parameters in **`model_parameters.m`** file in this format:

```matlab
params.SelfRepair = 1; % activates the SR
params.simPattern = 1; % set the inputs as numbers 0 to 3
params.impairmode = 2; % keep the network in healthy condition
```

In order to get the results, run `analytic_metrics.m` file. This simulation, depending on your PC configurations, takes around 16 hours to be simulated.

Since this simulation takes a long time to be done, we incorporated the saved output from our own simulations in `dataa` folder, in order to load those data and plot the outputs, you have to run `analyticPlot.m` file.

_To get the code and data to run this experiment, contact the corresponding author "**Mahmood Amiri"**._
