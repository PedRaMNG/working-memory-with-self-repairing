function [Ca, h, IP3, I_WM, array_I_neuro, Gli_local, Gli_global, I_WM_OHM] = ...
    step_astrocytes(neuron_astrozone_activity,neuron_astrozone_activity_OHM, spike, array_I_neuro, i, Ca, h, IP3, I_WM, Gli_local, I_sr, Gli_global)
    
    params          = model_parameters();
    diffusion_Ca    = zeros(params.mastro, params.mastro, 'double');
    diffusion_IP3   = zeros(params.mastro, params.mastro, 'double');
    I_WM_OHM        = zeros(params.mastro, params.mastro, 'logical');

    for j = 1 : params.mastro
        for k = 1 : params.nastro
            
            if neuron_astrozone_activity(j, k) > params.F_memorize     
                shift = fix(params.t_neuro / params.step) - 1;
                array_I_neuro(j, k, i : i + shift) = params.amplitude_neuro;
            end

            % Computes diffusion of calcium and IP3 in astrocyte network
            if (j == 1) && (k == 1)                             % Corner top left
                diffusion_Ca  = Ca(j + 1, k)  + Ca(j,k + 1)  - 2 * Ca(j,k);
                diffusion_IP3 = IP3(j + 1, k) + IP3(j,k + 1) - 2 * IP3(j,k);
            elseif (j == params.mastro) && (k == params.nastro) % Corner bottom right
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j,k - 1)  - 2 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j,k - 1) - 2 * IP3(j,k);
            elseif (j == 1) && (k == params.nastro)             % Corner top right
                diffusion_Ca  = Ca(j + 1, k)  + Ca(j,k - 1)  - 2 * Ca(j,k);
                diffusion_IP3 = IP3(j + 1, k) + IP3(j,k - 1) - 2 * IP3(j,k);
            elseif (j == params.mastro) && (k == 1)             % Corner bottom left
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j,k + 1)  - 2 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j,k + 1) - 2 * IP3(j,k);
            elseif j == 1                                       % First top row
                diffusion_Ca  = Ca(j + 1, k)  + Ca(j, k - 1)  + Ca(j,k + 1)  - 3 * Ca(j,k);
                diffusion_IP3 = IP3(j + 1, k) + IP3(j, k - 1) + IP3(j,k + 1) - 3 * IP3(j,k);
            elseif j == params.mastro                           % Last bottom row
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j, k - 1)  + Ca(j,k + 1)  - 3 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j, k - 1) + IP3(j,k + 1) - 3 * IP3(j,k);
            elseif k == 1                                       % First left column
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j + 1, k)  + Ca(j,k + 1)  - 3 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j + 1, k) + IP3(j,k + 1) - 3 * IP3(j,k);
            elseif k == params.nastro                           % Last right column
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j + 1, k)  + Ca(j,k - 1)  - 3 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j + 1, k) + IP3(j,k - 1) - 3 * IP3(j,k);
            elseif (j > 1) && (j < params.mastro) && (k > 1) && (k < params.nastro) % remaining columns and ...
                                                                                    % rows in the middle
                diffusion_Ca  = Ca(j - 1, k)  + Ca(j + 1, k)  + Ca(j, k - 1)  + Ca(j,k + 1)  - 4 * Ca(j,k);
                diffusion_IP3 = IP3(j - 1, k) + IP3(j + 1, k) + IP3(j, k - 1) + IP3(j,k + 1) - 4 * IP3(j,k);
            end

            %% Astrocyte model
            X            = [Ca(j, k) h(j, k) IP3(j, k)];
            I_neuro        = array_I_neuro(j, k, i);
            % Solving astrocyte equasions using Rung-Kutta method in "runge_astro" function:
            if  params.SelfRepair == 1 % With SR
                w1      = runge_astro(0, X,                        I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), I_sr(j, k, 1));
                w2        = runge_astro(0, X + params.u2   .* w1', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), I_sr(j, k, 1));
                w3        = runge_astro(0, X + params.u2   .* w2', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), I_sr(j, k, 1));
                w4        = runge_astro(0, X + params.step .* w3', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), I_sr(j, k, 1));
            else % without SR
                w1        = runge_astro(0, X,                      I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), 0*I_sr(j, k, 1));
                w2        = runge_astro(0, X + params.u2   .* w1', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), 0*I_sr(j, k, 1));
                w3        = runge_astro(0, X + params.u2   .* w2', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), 0*I_sr(j, k, 1));
                w4        = runge_astro(0, X + params.step .* w3', I_neuro, diffusion_Ca, diffusion_IP3, Gli_global(j,k), 0*I_sr(j, k, 1));
            end
            X            = X + params.u6 .* (w1' + 2 .* w2' + 2 .* w3' + w4');
            Ca(j, k)     = X(1);
            h(j, k)      = X(2);
            IP3(j, k)    = X(3);
                        
            %% Astrocyte event occurs and impact on connected neurons
            
            bnh = rem(i, params.shift_window_astro_watch);              % Added to adjust the time step of astrocytes

            if (Ca(j, k) > params.ca_threshold_global) && (bnh == 0)    % After every 10 steps, it checks this condition

                % Now that the astrocyte has enought calcium, it checks for every astrocyte that whether it 
                % recieved any synchronous activity from its supervising neurons.
                % Synchronous activity is defined when half or more ("params.F_recall") of the supervising 
                % neurons fired 100 time steps ago ("params.window_astro_watch"). 

                if i-params.window_astro_watch <= 0
                    
                    % For initial simulation time which there is less than "params.window_astro_watch" time steps,
                    % it checks from the zero.
                    Fin = any(spike(j, k, 1:i) >= params.F_recall);

                else
                    
                    % For the rest of simulation time where there is enought time for a 
                    % "params.window_astro_watch" long window to look back at.
                    % what does 'any' do? since it does not matter at which time step, this operation is used.
                    % This state however, will be updated as frequently as the "params.shift_window_astro_watch"
                    Fin = any(spike(j, k, (i - params.window_astro_watch) : i) >= params.F_recall);

                end 
                
                if Fin > 0
                    
                    % Impact of astrocytes on supervising neurons for imply working memmory perpuses for the next
                    % "params.impact_astro" time steps. Note that this will also be updated throughout the 
                    % simulation time.
                    I_WM(j, k, i : i + params.impact_astro) = 1;

                end

            end
            
            % Local gliotransmitter for SR 
            if Ca(j, k) > params.ca_threshold_Local 
                % gliotransmitter release from astrocytes
                Gli_local(j,k) = Gli_local(j,k) + params.step*(params.r_Glu - (Gli_local(j,k)/params.tau_Glu)); 
            else
                % gliotransmitter decay rate
                Gli_local(j,k) = Gli_local(j,k) + params.step*(-1*(Gli_local(j,k)/params.tau_Glu));      
            end
            
            % Whole-cell gliotransmitter for WM 
            if (Ca(j, k) > params.ca_threshold_global) && (I_WM(j,k,i)) 
                % gliotransmitter release from astrocytes
                Gli_global(j,k) = Gli_global(j,k) + params.step*(params.r_Glu*1.5/0.035 - (Gli_global(j,k)/params.tau_Glu)); 
            else
                % gliotransmitter decay rate
                Gli_global(j,k) = Gli_global(j,k) + params.step*(-1*(Gli_global(j,k)/(params.tau_Glu*0.4)));      
            end
            Gli_global(j,k) = min(Gli_global(j,k), 1);

        end
    end
end