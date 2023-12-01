function I_poisson_noise = make_poisson_noise()
    params = model_parameters();

    T_step                    = 1 / params.poisson_nu / params.step;
    T_poisson                 = poissrnd(T_step, params.quantity_neurons, params.poisson_n_impulses);
    amplitude                 = (rand(params.quantity_neurons, params.poisson_n_impulses) - 0.5) * 2;
    amplitude                 = amplitude * params.poisson_amplitude;
    T_poisson(:,1)            = fix(params.poisson_impulse_initphase * rand(params.quantity_neurons, 1));
    T_poisson(T_poisson == 0) = 1;
    T_poisson                 = cumsum(T_poisson, 2);
    
    I_poisson_noise           = zeros(params.quantity_neurons, max(T_poisson, [], 'all'));
    I_poisson_noise           = single(I_poisson_noise);
    
    for j = 1:params.quantity_neurons
        for i = 1:params.poisson_n_impulses
            be = T_poisson(j, i);
            en = T_poisson(j, i) + params.poisson_impulse_duration;
            I_poisson_noise(j, be:en) = amplitude(j, i);
        end
    end
    
    I_poisson_noise           = shiftdim(I_poisson_noise(:,1 : params.n + 1));
    I_poisson_noise           = single(I_poisson_noise);
end

