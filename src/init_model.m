function model = init_model()

    model = struct;
    params = model_parameters();
    model.T = 0:params.step:params.t_end;
    model.T = single(model.T);

    model.Post = zeros(1, params.quantity_connections, 'int8');
    model.Pre = zeros(1, params.quantity_connections, 'int8');

    %% Neurons
    model.V_line = zeros(params.quantity_neurons, params.n, 'double');
    model.Isumm = zeros(params.quantity_neurons, params.n, 'double');
    model.V_line(:, 1) = params.v_0;
    model.G = zeros(params.quantity_neurons, params.n, 'double');
    model.G2 = zeros(params.quantity_neurons, params.n, 'double');
    model.U_line = zeros(params.quantity_neurons, 1, 'double');
    model.Isyn_line = zeros(params.quantity_neurons, params.n, 'double');
    model.I_WM_line = zeros(params.quantity_neurons, 1, 'logical');
    model.Mask_line = zeros(1, params.quantity_neurons, 'logical');
    model.ohm = zeros(params.quantity_neurons, params.n, 'double');

    %% Neuron activity
    model.neuron_astrozone_activity_spike = zeros(params.mastro, params.nastro, params.n); 
    model.neuron_astrozone_activity_OHM = zeros(params.mastro, params.nastro, params.n);
    model.neuron_astrozone_spikes = zeros(params.mastro, params.nastro, params.n, 'int8');

    %% Astrocytes
    model.Ineuro = zeros(params.mastro, params.nastro, params.n, 'int8');
    model.I_WM = zeros(params.mastro, params.nastro, params.n, 'logical');
    model.I_WM_OHM  = zeros(params.mastro, params.nastro, params.n, 'logical');
    model.Ca = zeros(params.mastro, params.nastro, 1, 'double');
    model.Ca_expand = zeros(params.mneuro, params.nneuro, params.n, 'double');
    model.H = zeros(params.mastro, params.nastro, params.n, 'double');
    model.IP3 = zeros(params.mastro, params.nastro, params.n, 'double');
    model.Ca(:, :, 1) = params.ca_0;
    model.H(:, :, 1) = params.h_0;
    model.IP3(:, :, 1) = params.ip3_0;
    model.Gli_global = zeros(params.mastro, params.nastro, params.n, 'double');
    model.Gli_global_expand = zeros(params.mneuro, params.nneuro, 1, 'double');

    %% SELF REPAIRING
    model.AG = zeros(params.quantity_neurons, params.n, 'double');
    model.BoF = zeros(params.quantity_neurons, params.n, 'double');
    model.eSP_expand_line = zeros(params.quantity_neurons, params.n, 'double');
    model.Gli_local = zeros(params.mastro, params.nastro, params.n, 'double');
    model.Gli_local_expand = zeros(params.mneuro, params.nneuro, 1, 'double');
    model.numofIsyn = zeros(params.quantity_neurons, params.n, 'int8');
    model.I_SR = zeros(params.quantity_neurons, params.n, 'logical'); 
    model.SoI = zeros(params.quantity_neurons, params.n, 'double');
    model.I_SR_astro = zeros(params.mastro, params.nastro, params.n, 'int8');

    %% Iapp and record video
    model.Iapp_v_full = zeros(params.mneuro, params.nneuro, params.n, 'uint8');

    %% Prepare model
    [model.images, model.Tumor] = load_images(params.simPattern);
    model.I_poisson_noise = make_poisson_noise();
    [model.Post, model.Pre] = create_connections();
    [model.Post2, indi] = sort(model.Post);
    model.Pre2 = model.Pre(indi);
    model.numofPost = zeros(params.mneuro * params.nneuro, 1, 'double');

    for i = 1:params.quantity_connections
        model.numofPost(model.Post2(i)) = model.numofPost(model.Post2(i)) + 1;
    end

    [model.Iapp, model.T_Iapp, model.T_Iapp_met, model.T_record_met] = make_experiment(model.images);

    %% Network Damage mode
    [model.ST1, model.ST2] = impair(params.impairmode, params.quantity_connections, params, model.Tumor, model.numofPost, model.Post);
    
end
