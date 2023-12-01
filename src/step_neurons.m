function model = step_neurons(model, params, i)

    %% inputs
    V = model.V_line(:, i);
    U = model.U_line(:, 1);
    G = model.G(:, i);
    G2 = model.G2(:, i);
    AG = model.AG(:, i);
    eSP_expand_line = model.eSP_expand_line(:, i);
    t_Iapp_met = model.T_Iapp_met(i);
    array_Iapp = model.Iapp;
    Isyn = model.Isyn_line(:, i);
    Post = model.Post;
    Pre = model.Pre;
    numofPost = model.numofPost;
    I_WM = model.I_WM_line(:, 1);
    I_poisson_noise = model.I_poisson_noise(:, i);
    ST1 = model.ST1;
    ST2 = model.ST2;
    SoI = model.SoI(:, i);
    Gli_local_expand = model.Gli_local_expand;
    Gli_global_expand = model.Gli_global_expand;


    %% -------------------------------------------------------------------------------------------
    I_WM = double(I_WM);
    I_poisson_noise = double(I_poisson_noise);

    %% Input image as rectangle function of applied current to neuronal layer
    if t_Iapp_met == 0
        Iapp = zeros(params.mneuro, params.nneuro, 'uint8');
    else
        Iapp = array_Iapp(:, :, t_Iapp_met); % for the timeline of applied input
    end

    %% Izhikevich neuron model
    % Since Izhikevich model is a fitted model, a hard limit on its applied current and maximum voltage is ...
    % needed to keep the differential equations functioning.
    Iapp_line   = Iapp(:);
    Gli_local_expand_line   = Gli_local_expand(:);
    Gli_global_expand_line  = Gli_global_expand(:);
    Iapp_line   = double(Iapp_line);
    fired       = find(V >= params.neuron_fired_thr);
    V(fired)    = params.c; % After-spike reset value of the membrane potential
    U(fired)    = U(fired) + params.d; % After-spike reset value of the recovery variable
    I_sum       = Iapp_line + Isyn + ST2' .* I_poisson_noise;
    I_sum       = min(I_sum, params.I_input_thr); % The final value should not be greater than I_thr
    ISUM        = I_sum; % used for plot
    V           = V + params.step .* 1000 .* (0.04 .* (V .^ 2) + (5 .* V) + 140 + I_sum - U);
    U           = U + params.step .* 1000 .* params.aa .* (params.b .* V - U);
    V           = min(V, params.neuron_fired_thr); % The final value should not be greater than V_thr
    del         = zeros(params.quantity_neurons, 1); % spike event
    del(V == params.neuron_fired_thr) = 1;
    
    %% Self-Repairing

    % 2-AG & DSE release when post firing
    AG  = AG + params.step .* (params.r_AG .* del - AG ./ params.tau_AG);
    DSE = AG * params.k_DSE;

    % eSP
    OHM = params.gamma_glu*G + params.gamma_AG*AG; % Since in step_astro, the Gli_local would be calculated for all
    % supervising neurons, this condition is applied here to assess these conditions for each neuron 
    SoIMapp   = 0.8 * SoI .^ 0.1; 
    eSP_expand_line = eSP_expand_line + params.step .* ((-eSP_expand_line + ...
        (params.k_eSP.*SoIMapp.*Gli_local_expand_line).*((Iapp_line>= 0.01|I_WM)&(OHM>=params.OHM_recall_local)))./params.tau_eSP); 
    BoF = eSP_expand_line + DSE; 
    BoF = (BoF ./ 100 + 1) * 1;
    I_SR = BoF >= 1.01; 
    
    %% Neuron synaptic currents
    mask = zeros(params.quantity_neurons, 1, 'logical');
    mask(V > params.neuron_fired_thr - 1) = 1;
    S = 1 ./ (1 + exp((-V ./ params.ksyn)));

    gsync = ST1' .* (params.Eta_syn +I_WM(Post) .* Gli_global_expand_line(Post) .* params.Eta_WM ...
                    + (I_SR(Post) .* params.Eta_SR) .* (params.SelfRepair == 1) );

    Isync = gsync .* S(Pre) .* (params.Esyn - V(Post));

    numofIsyn = zeros(params.mneuro * params.nneuro, 1, 'int8');

    Isyn = zeros(params.quantity_neurons, 1, 'double');
    
    for j = 1:params.quantity_connections
        Isyn(Post(j)) = Isyn(Post(j)) + Isync(j);
        % This condition is added to eliminate the negative current spikes
        numofIsyn(Post(j)) = numofIsyn(Post(j)) + int8((Isync(j) > 0.001)); 
    end

    SoI = double(numofIsyn) ./ double(numofPost); 

    switch params.GluType
        case 1
            G2 = G2 + params.step .* (params.k2 .* SoI - G2 .* params.alf) .* (ST2)';
            G = G + params.step .* (params.k .* del - G .* params.alf);
        case 2
            G = G + params.step .* (params.k2 .* SoI - G .* params.alf) .* (ST2)';
            G2 = G2 + params.step .* (params.k .* del - G2 .* params.alf);
    end

    %% -------------------------------------------------------------------------------------------

    %% outputs
    model.V_line(:, i + 1) = V;
    model.U_line(:, 1) = U;
    model.G(:, i + 1) = G;
    model.G2(:, i + 1) = G2;
    model.AG(:, i + 1) = AG;
    model.eSP_expand_line(:, i + 1) = eSP_expand_line;
    model.BoF(:, i) = BoF;
    model.Isyn_line(:, i + 1) = Isyn;
    model.Mask_line = mask;
    model.Iapp_v_full(:, :, i) = Iapp;
    model.Isumm(:, i + 1) = ISUM;
    model.numofIsyn(:, i + 1) = numofIsyn;
    model.SoI(:, i + 1) = SoI;
    model.Gli_local_expand_line(:, i + 1) = Gli_local_expand_line;
    model.I_SR(:, i + 1) = I_SR;

end
