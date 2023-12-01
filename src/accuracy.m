function [accurac, tLine] = accuracy(params, model)
    vLine                = model.V_line;
    wind                = 20;
    window                = wind * 10;                                    % n steps for find spike
    shiftWindow            = 4;

    accurac                = zeros(params.n, length(params.learn_order));    % Number of learning images
    img                    = cell(length(params.learn_order), 1);
    background            = zeros(length(params.learn_order), 1);
    pattern                = zeros(length(params.learn_order), 1);
    cout                = 1;

    for i = 1:length(params.learn_order)
        img{i}            = model.images{i}(1 : params.mneuro, 1 : params.nneuro) < 127;
        img{i}            = img{i}(:);
        background(i)    = sum(img{i} == 0);
        pattern(i)        = sum(img{i} == 1);
    end

    for i = (window + 1):shiftWindow:params.n
        nTrueBackground    = zeros(length(params.learn_order), 1);
        nTruePattern    = zeros(length(params.learn_order), 1);
        mask            = zeros(params.quantity_neurons, 1);
        for j = 1:params.quantity_neurons
            mask(j) = double(any(vLine(j, (i - window):i) > 0));
            for jj = 1:length(params.learn_order)
                if (img{jj}(j) == 0) && (mask(j) == 0)
                    nTrueBackground(jj) = nTrueBackground(jj) + 1;
                end
                if (img{jj}(j) == 1) && (mask(j) == 1)
                    nTruePattern(jj) = nTruePattern(jj) + 1;
                end
                accurac(cout, jj) = (nTrueBackground(jj) / background(jj) + nTruePattern(jj) /pattern(jj)) / 2;
            end
        end
        if mod(i,1000) < (shiftWindow + 1); disp([num2str(params.n), ' - ', num2str(i)]); end
        cout = cout + 1;
    end
    tLine = linspace(window, params.n, cout - 1);
    accurac = accurac(1:(cout - 1), :)';
end

