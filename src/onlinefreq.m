function [dFreq, smoOoth] = onlinefreq(sign, winwid, steps, sampletime, pOl, maxAmp)
    % (signal, window_width, each_step_shifted_window, sampling_time,
    % smoother_pole, maximum_amplitude);
    
    sign    = sign(:);
    n       = numel(sign);
    dFreq   = zeros(n, 1);
    window  = ones(winwid,1);
    h2      = sampletime*winwid;
    
    for t = 1:steps:(n-winwid)
        h1    = sign(t:(t+winwid-1)).*window;
        Fre   = sum(h1 == maxAmp)/h2;
        dFreq(t:(t + steps - 1)) = repmat( Fre , 1, steps);
        
    end
    g        = tf(1, [pOl, 1]);
    timeline = linspace(0, numel(dFreq)*sampletime, numel(dFreq));
    smoOoth  = lsim(g, dFreq, timeline);
end

