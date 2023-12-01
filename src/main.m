try
    tic;
    %% Initialization
    % close all; 
    clearvars; clc;
    rng(42);

    params = model_parameters(1);
    model  = init_model();
    disp(1);
       
    %% Simulation
    [model] = simulate_model(model, params);
    
    %% Visualization of learning and testing processes
    %  Video consist of 3 frames (left to right):
    %  1. input pattern
    %  2. neuron layer
    %  3. astrocyte layer
    
    [model.video] = make_video(model.Ca_expand, ...
        model.V_line,            ...
        model.Iapp_v_full,       ...
        model.T_record_met);
    colrs = [255, 255, 255;
             110, 109, 98;
             29, 67, 80;
             243, 144, 79]/255; 
    locs = [0,      ...
            0.33,   ...
            0.66,   ...
            1];
    pro.limits = [0, 255]; 
    pro.fps = 100;
    pro.cmap = makeGradient(256, colrs, locs, 1);
    show_video(model.video, pro);
    
    %% Snapshots (Predicted learned images)
    show_video(memory_performance.freq_images, pro);         % by frequency % run this
    % show_video(memory_performance.spike_images_best_thr);  % by threshold
    
    %% WM and SR modulaitons videoes
    colrs = [255, 255, 255;
             110, 109, 98;
             29, 67, 80;
             243, 144, 79]/255;
    locs = [0,      ...
            0.30,   ...
            0.7,   ...
            1];
    pro.limits = [0, 1];
    % pro.cmap = makeGradient(256, colrs, locs, 1); %run this if you want to see the gradient color
    show_video(model.Gli_global, pro); 
    I_SR_2D = reshape(model.I_SR, [params.mneuro, params.nneuro, params.n]);
    show_video(I_SR_2D, pro);

  toc;
    
%% Plot or Save data
    run Plots.m
%     run saveData.m
catch ME
    if (strcmp(ME.identifier,'MATLAB:nomem'))
        error('Out of memory. Please, increase the amount of available memory or change the simulation settings to not save unnecessary data. \nThe minimum required amount of RAM is 16 GB.', 0);
    else
        rethrow(ME);
    end
end

