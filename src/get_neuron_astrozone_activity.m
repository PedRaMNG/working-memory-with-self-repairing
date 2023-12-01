function [neuron_astrozone_activity_spike, neuron_astrozone_activity_OHM, neuron_astrozone_spikes, I_SR_astro] ...
    = get_neuron_astrozone_activity_spike(G, AG, Mask_line, I_SR)
    params = model_parameters();
    mask1  = reshape(Mask_line, params.mneuro, params.nneuro);
    mask1  = single(mask1);
    
    % Detects any neuron that passes the glutamate threshold
    OHM = params.gamma_glu*G + params.gamma_AG*AG;
    
    Total_OHM_passed = reshape(OHM >= params.OHM_memorize, params.mneuro, params.nneuro); 
    Total_OHM = reshape(OHM, params.mneuro, params.nneuro);

    Isr_above_thr = reshape(I_SR > 0, params.mneuro, params.nneuro);
    
    neuron_astrozone_activity_spike = zeros(params.mastro, params.nastro); 
    neuron_astrozone_activity_OHM = zeros(params.mastro, params.nastro); 
    neuron_astrozone_spikes   = zeros(params.mastro, params.nastro, 'int8'); 
    I_SR_astro                  = zeros(params.mastro, params.nastro, 'int8');
    sj = 0;
    for j = 1 : params.az : (params.mneuro - params.az)
        sk = 0;
        for k = 1 : params.az : (params.nneuro - params.az)
            % Number of neurons that passed the glu threshold
            neuron_astrozone_activity_spike(j - sj, k - sk) = ... 
                sum(Total_OHM_passed(j : j + params.az, k : k + params.az), 'all');
            % total amount of released neurotransmitters
            neuron_astrozone_activity_OHM(j - sj, k - sk) = ... 
                sum(Total_OHM(j : j + params.az, k : k + params.az), 'all');
            % Number of neurons spiking
            neuron_astrozone_spikes(j - sj, k - sk) = ...
                sum(mask1(j : j + params.az, k : k + params.az), 'all');
            % I_sr Expand
            I_SR_astro(j - sj, k - sk) = ...
                sum(Isr_above_thr(j : j + params.az, k : k + params.az), 'all');
            sk = sk + 2;
        end
        sj = sj + 2;
        
    end
end




