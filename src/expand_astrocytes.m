function [I_WM_expanded, Ca_expanded, Gli_local_expand, Gli_global_expand] = ...
    expand_astrocytes(Ca, I_WM, Gli_local, Gli_global)
    % Expands astrocyte calcium concentration and electrical currents
    % to connected neurons
    params = model_parameters();

    km = 0;
    I_WM_expanded = false(params.mneuro, params.nneuro);

    for j = 1:params.az:(params.mneuro - params.az)
        kmm = 0;

        for k = 1:params.az:(params.nneuro - params.az)
            % Expand working memmory's affect on all of supervising neurons
            % I_WM_expanded(j : j + params.az, k : k + params.az) = I_WM(j - km, k - kmm);

            % spike
            HELP(1:1 + params.az, 1:1 + params.az) = I_WM(j - km, k - kmm);
            I_WM_expanded(j:j + params.az, k:k + params.az) = ...
                I_WM_expanded(j:j + params.az, k:k + params.az) | HELP;
            % cal
            Ca_expanded(j:j + params.az, k:k + params.az) = Ca(j - km, k - kmm);
            % Glio
            Gli_global_expand(j:j + params.az, k:k + params.az) = Gli_global(j - km, k - kmm);
            Gli_local_expand(j:j + params.az, k:k + params.az) = Gli_local(j - km, k - kmm);
            kmm = kmm + 2;
        end
        km = km + 2;
    end

    I_WM_expanded = I_WM_expanded(:)';
    
end
