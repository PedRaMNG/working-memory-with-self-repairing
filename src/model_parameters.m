function [params] = model_parameters(need_set)
    persistent params_p
    if nargin < 1 || ~need_set
        params = params_p;
        return;
    end
    params = struct;
    
    % Self-Repairing modulation of astrocyte
    params.SelfRepair = 1; % Active (1), Inactive (0)
    params.GluType    = 2; % Type 1 Glu is using del 
                           % Type 2 Glu is using SoI %this is the proposed method in the paper
    
    % simulation setup: Inputs and size of the network
    params.simPattern = 1;
        % Pattern set 1 = 79 x 79 (main: 0-3)
        % Pattern set 2 = 79 x 79 (two strips)
    
    %% synaptic Damage Modes
    params.impairmode  = 0;     % Damages synaptic connections
        %Scenario 0: Healthy network         % Experiment 1
        %Scenario 1: Random with fixed amp
        %Scenario 2: Random with random amp  % Experiment 4
        %Scenario 3: pattern specific        % Experiment 2 & 3
    
    % settings of damage modes 1 & 2 
    params.scenario1a2.probability = 1; % The more it is, the more neuronsare being damaged
    params.scenario1a2.amplitude   = 0; % The smaller it is, the more damage is being applied 
                                        % In scenario 2 the minimun healthiness is defined with this variable

    %% Astrocytes Damage modes
    params.impairAstro = 0;

    %% Timeline
    switch params.simPattern
        case 1
            params.t_end = 6;
        case 2
            params.t_end = 3.5;
    end
    
    params.step = 0.0001; %second
    params.n    = fix(params.t_end / params.step);
    
    %% Experiment
    switch params.simPattern
        case 1 % main
            params.learn_start_time       = 0.5;
            params.learn_impulse_duration = 0.2;
            params.learn_impulse_shift    = 0.3;
            params.learn_order            = [0, 1, 2, 3] + 1;
            
            params.test_start_time       = 2.3;
            params.test_impulse_duration = 0.15; 
            params.test_impulse_shift    = 0.45; 
            params.test_order            = [0, 5, 1, 2, 6, 9, 3, 8] + 1;
        case 2 % 2 strips
            params.learn_start_time       = 0.2;
            params.learn_impulse_duration = 0.2;
            params.learn_impulse_shift    = 0.3;
            params.learn_order            = [0, 1] + 1;
            
            params.test_start_time       = 2;
            params.test_impulse_duration = 0.15;
            params.test_impulse_shift    = 0.4;
            params.test_order            = [0, 1] + 1;
    end 
    
    %% Applied pattern current
    if params.simPattern == 1
        params.variance_learn = 0.05;
        params.variance_test  = 0.2;
        params.Iapp_learn     = 10;
        params.Iapp_test      = 8;
    elseif params.simPattern == 2
        params.variance_learn = 0;  
        params.variance_test  = 0;   
        params.Iapp_learn     = 10;    
        params.Iapp_test      = 8;     
    end

    %% Movie
    params.after_sample_frames      = 200;
    params.before_sample_frames     = 1;

    %% Poisson noise
    params.poisson_nu                = 1.5;
    params.poisson_n_impulses        = 15; 
    params.poisson_impulse_duration  = fix(0.03 / params.step);
    params.poisson_impulse_initphase = fix(1.5 / params.step);
    params.poisson_amplitude         = 20;

    %% Runge-Kutta steps
    params.u2 = params.step / 2;
    params.u6 = params.step / 6;

    params.mneuro = 79;
    params.nneuro = 79;
    params.quantity_neurons = params.mneuro * params.nneuro;
    params.mastro = 26;
    params.nastro = 26;
    az = 4;             % Astrosyte zone size
    params.az = az - 1;
    
    %% Initial conditions
    params.v_0   = -70;
    params.ca_0  = 0.072495;
    params.h_0   = 0.886314;
    params.ip3_0 = 0.820204;

    %% Neuron model
    params.aa  = 0.1;    %FS        % Time scale of the recovery variable
    params.b   = 0.2;
    params.c   = -65;
    params.d   = 2;
    params.alf = 10;               % s^-1    | Glutamate clearance constant
    params.k   = 600;              % uM.s^-1 | Efficacy of glutamate release
    params.k2  = 400;              % uM/s
    params.neuron_fired_thr = 30;        % Maxium amount of input current for presynaptic neurons
    params.I_input_thr      = 25;  %25   % Maxium amount of voltage out of a neuron

    params.N_connections = 40; % number of synapses per neurons 
    params.lambda = 5;         % Average exponential distribution

    % Noumber of all synaptic connections:
    params.quantity_connections = params.quantity_neurons * params.N_connections; 
    params.beta = 5;
    % Synaptic weight without astrocytic influence:
    params.Eta_syn = 0.02;      
    % Being excitatory or inhibitory synapse
    params.Esyn = 0;            % presynaptic neuorn voltage
    params.ksyn = 0.2;          % Slope of the synaptic activation function
    % Astrocyte modulation parameter for WM
    params.Eta_WM = 0.4;
    
    %% Neuron-Astrocyte
    params.t_neuro = 0.06;        % Global Astrocyte modulation duration (second)
    params.amplitude_neuro = 5;   % Astrocyte input
    params.amplitude_neuro2 = 6; % should be removed
    params.gamma_glu = 0.4;      
    params.gamma_AG = 0.6;       
    
    %% Astrosyte model
    params.dCa = 0.05;
    params.dIP3 = 0.1;      
    params.zeta_SR = 0.02;  
    params.zeta_WM = 0.5;  
    % astrocyte watching neurons this much back with bnh intervals
    window_astro_watch = 0.01; % t(sec) 
    shift_window_astro_watch = 0.001; % t(sec) 
    impact_astro = 0.25; % t(sec) 
    params.impact_astro = fix(impact_astro / params.step);
    params.window_astro_watch = fix(window_astro_watch / params.step);
    params.shift_window_astro_watch = fix(shift_window_astro_watch / params.step);
    
    params.F_memorize = 8;             % minimum number of neurons higher than 0.7 threshold of glutamate & 2AG
    params.F_recall   = 6;             % Spike activity of larger than or equal to this,
                                       % astrocytes start to impact the neurons
    params.OHM_memorize = 0.7;         % minimum sum of glutamate & 2AG for memorize
    params.OHM_recall_local    = 0.2;
    params.OHM_recall_global   = 6*0.7;       
    params.ca_threshold_global = 0.15; % 0.15    

    %% Memory performance
    params.max_spikes_thr = 30;
    
    %% Self-repairing 
    params.r_AG = 800;        
    params.tau_AG = 0.1;      
    params.tau_eSP = 0.08;    
    params.k_eSP = 800;       
    params.k_DSE = -6;          
    % Glutamate release from astrocyte 
    params.ca_threshold_Local = 0.1; 
    params.tau_Glu = 0.1;      
    params.r_Glu = 0.35;      
    params.Eta_SR = 0.5;      
    
    %% 
    params_p = params;
end

