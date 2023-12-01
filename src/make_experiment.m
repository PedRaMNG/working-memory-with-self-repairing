function [I_signals, full_timeline, timeline_signal_id, timeline_signal_id_movie] = make_experiment(images)
    
    params = model_parameters();

    num_images = length(images);
    % Make image signals --------------------------
    if isfield(params, 'learn_order')
        learn_order = params.learn_order;
    else
        learn_order = make_image_order(num_images, 10, true);
    end
    learn_signals = make_noise_signals(images, ...
                                       learn_order, ...
                                       params.mneuro, ...
                                       params.nneuro, ...
                                       params.variance_learn, ...
                                       params.Iapp_learn);
    
    if isfield(params, 'test_order')
        test_order = params.test_order;
    else
        test_order = make_image_order(num_images, 1, true);
    end
    test_signals = make_noise_signals(images, ...
                                      test_order, ...
                                      params.mneuro, ...
                                      params.nneuro, ...
                                      params.variance_test, ...
                                      params.Iapp_test);
        
    I_signals = cat(3, learn_signals, test_signals);
    I_signals = uint8(I_signals);
    % Make image signals -------------------------------------------------#

    learn_timeline = make_timeline(params.learn_start_time, ...
                                   params.learn_impulse_duration, ...
                                   params.learn_impulse_shift, ...
                                   length(learn_order));
    test_timeline  = make_timeline(params.test_start_time, ...
                                   params.test_impulse_duration, ...
                                   params.test_impulse_shift, ...
                                   length(test_order));
    
    full_timeline = [learn_timeline; test_timeline];
    full_timeline = fix(full_timeline ./ params.step);
    full_timeline = uint32(full_timeline); % Fix problem 12/24/2021
    %----------------------------------------------------------------------
    
    timeline_signal_id = zeros(1, params.n, 'uint8');
    timeline_signal_id_movie = zeros(1, params.n, 'uint8');
    
    for i = 1 : size(I_signals, 3)
        be = full_timeline(i, 1);
        en = full_timeline(i, 2);
        timeline_signal_id(be : en) = i;
        
        be = be - params.before_sample_frames;
        en = en + params.after_sample_frames;
        
        timeline_signal_id_movie(be : en) = i;
    end
end

function [image_order] = make_image_order(num_images, num_repetitions, need_shuffle)
    image_order = [];
    for id_image = 1:num_images
        for j = 1:num_repetitions
            image_order(end + 1) = id_image;
        end
    end
    if need_shuffle
        image_order = image_order(randperm(length(image_order)));
    end
end

function signals = make_noise_signals(images, order, height, width, variance, Iapp0)
    signals = zeros(height, width, length(order), 'double');
    for i = 1:length(order)
        image_id         = order(i);
        signal           = make_noise_signal(images{image_id}, height, width, variance, Iapp0);
        signals(:, :, i) = signal;
    end
end

function image = make_noise_signal(image, height, width, variance, Iapp0, thr)
    if nargin < 6
        thr = 127;
    end
    image = image(1 : height, 1 : width) < thr;
    p = randperm(width * height);
    b = p(1 : uint16(width * height * variance));
    image(b) = ~image(b);
    image = double(image) .* Iapp0;
end

function timeline = make_timeline(start, duration, step, num_samples)
    timeline = zeros(num_samples, 2, 'double');
    for i = 1:num_samples
        be             = start + step * (i - 1);
        en             = be + duration;
        timeline(i, :) = [be, en];
    end
end

