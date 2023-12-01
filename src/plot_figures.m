function ress = plot_figures(model, params, opt)

    % Show or not vars
    plotNeuronVoltage       = opt.plotNeuronVoltage;      %1% Single Neuron Voltage and Glutamate
    plotSpikeRaster         = opt.plotSpikeRaster;        %3% Voltage   Map
    plotIappMAP             = opt.plotIappMAP;            %5% I applied Map
    plotCalIP3              = opt.plotCalIP3;             %7% Calcium and IP3
    plotSR                  = opt.plotSR;                 %10% DSE, eSP, BoF, Gli_local, and 2AG
    plotAccuracy            = opt.plotAccuracy;           %13% Accuracy
    plotIneuroAstro         = opt.plotIneuroAstro;        %14% I neuro astro
    plotI_SR                = opt.plotI_SR;               %15% I SR
    plotGli_global          = opt.Gli_global;             %16% Gli global
    vectime                 = opt.Time;                   % Gets time interval

    % Time variables
    Time = model.T(2:end);
    tline = 1:params.n;

    if vectime == 0
        vectime = [0, params.t_end];
    end

    vectimen = floor(vectime / params.step);

    % Part 1 vars - Single Neuron voltage and Glutamate
    voltageFrequencyBandwidth = opt.voltageFrequencyBandwidth;
    voltageFrequencyBandShift = opt.voltageFrequencyShiftShift;
    voltageFrequencySmoother = opt.voltageFrequencySmoother;

    % Part 7, 8 vars: [j, k]
    numofAstro = opt.numofAstro;

    % Part 1 & 9 vars: [j, k]
    numofNeuro = opt.numofNeuro;

    %MAP color BRG
    MAPcolor1 = opt.MAPcolor1;
    MAPcolor2 = opt.MAPcolor2;

    backOpacity = opt.Opacity;

    % R - G - B
    clrs = [0, 114, 189;
                 217, 83, 25;
                 237, 177, 32;
                 126, 47, 142;
                 119, 172, 48;
                 77, 190, 238;
                 162, 20, 47] / 255; %jet(size(numofAstro,1))
    noc = size(clrs, 1);

    % Linestyle plot
    linestyle = {'-', ... %Solid line
                 '--', ... %Dashed line
                 '-.', ... %Dash-dotted line
                 ':'}; ... %Dotted line
    nols = numel(linestyle);
    dam = damageBackground(model.Tumor, params.n);
    damage = makeImage(dam, MAPcolor2);

    %% Part 1 - Single Voltage and Glutamit
    if plotNeuronVoltage ~= 0
        disp('Started - plotNeuronVoltage');
        ssi = setsizee(plotNeuronVoltage);
        figure(); ssi();
        subplot(511);
        hold on;
        plotSecAreas(model, params.step, [-200, 200]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.V_line(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 0.5, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('Voltage (mV)');
        ylim([1.1 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(512);
        hold on;
        plotSecAreas(model, params.step, [-100, 100]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.G(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('Glutamate');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(513);
        hold on;
        plotSecAreas(model, params.step, [-100, 100]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.AG(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('2AG');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(514);
        hold on;
        plotSecAreas(model, params.step, [-100, 100]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = params.gamma_glu * model.G(neurInd, :) + params.gamma_AG * model.AG(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('OHM');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(515);
        hold on;
        plotSecAreas(model, params.step, [-100, 1000]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            [~, siGnal] = onlinefreq(model.V_line(neurInd, :)', ...
                voltageFrequencyBandwidth, ...
                voltageFrequencyBandShift, ...
                params.step, ...
                voltageFrequencySmoother, ...
                params.neuron_fired_thr); siGnal = siGnal';

            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        lgd = legend;
        title(lgd, 'Neurons(m,n)');
        ylabel('Fire frequency (Hz)');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        xlabel('Time (s)');
        disp('Finished!');
    end

    %% Part 3 - Spike raster
    if plotSpikeRaster ~= 0
        disp('Started - plotSpikeRaster');
        ssi = setsizee(plotSpikeRaster);
        BBC = model.V_line;
        BBC = BBC(:, tline);
        figure(); ssi();
        plot(0, 0); hold on;
        colrs = opt.colrs3;
        locs = opt.locs3;
        cmap = makeGradient(256, colrs, locs, 0);
        imagesc(BBC);
        colormap(cmap);
        colorbar;

        if opt.limits3
            caxis(opt.limits3);
        end

        im = image(damage);
        im.AlphaData = backOpacity;
        plotSecLines(model, 1, [0, size(BBC, 1) + 1]);
        xlabel('Time (s)');
        ylabel('Neurons');
        title('Spike Raster');
        xlim(vectimen);
        ylim([0.5, params.mneuro * params.nneuro + 0.5]);
        disp('Finished!');
    end

    %% Part 4 - Glutamate Map


    %% Part 5 - I applied map
    if plotIappMAP ~= 0
        disp('Started - plotIappMAP');
        ssi = setsizee(plotIappMAP);

        HH = zeros(params.mneuro * params.nneuro, params.n);
        k = 1;

        for j = 1:params.nneuro

            for i = 1:params.mneuro
                HH(k, :) = reshape(model.Iapp_v_full(i, j, :), [1, params.n]);
                k = k + 1;
            end

        end

        BBC = HH(:, tline);
        figure(); ssi();
        plot(0, 0); hold on;
        colrs = opt.colrs5;
        locs = opt.locs5;
        cmap = makeGradient(10, colrs, locs, 0);
        imagesc(BBC);
        colormap(cmap);
        colorbar;

        if opt.limits5
            caxis(opt.limits5);
        end

        im = image(damage);
        im.AlphaData = backOpacity;
        plotSecLines(model, 1, [0, size(BBC, 1) + 1]);
        xlabel('Time (s)');
        ylabel('Neurons');
        title('I Applied Map');
        xlim(vectimen);
        ylim([0.5, params.mneuro * params.nneuro + 0.5]);
        disp('Finished!');
    end

    %% Part 6 - Calcium Map and Mean of that

    %% Part 7 - Calcium and IP3
    if plotCalIP3 ~= 0
        disp('Started - plotCalIP3');
        ssi = setsizee(plotCalIP3);

        figure(); ssi();
        subplot(211);
        hold on;
        plotSecAreas(model, params.step, [0, 10]);
        miny = 0; maxy = 0;

        for k = 1:size(numofAstro, 1)
            % siGnal = reshape(model.Ca(numofAstro(k, 1), numofAstro(k, 2), :), [1, params.n]);
            siGnal = reshape(model.Gli_global(numofAstro(k, 1), numofAstro(k, 2), :), [1, params.n]);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofAstro(k, 1)), ', ', num2str(numofAstro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        lgd = legend;
        title(lgd, 'Astrocytes(j,k)');
        ylabel('Calcium');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(212);
        hold on;
        plotSecAreas(model, params.step, [0, 30]);
        miny = 0; maxy = 0;

        for k = 1:size(numofAstro, 1)
            siGnal = reshape(model.IP3(numofAstro(k, 1), numofAstro(k, 2), :), [1, params.n]);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofAstro(k, 1)), ', ', num2str(numofAstro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('IP3');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        xlabel('Time (s)');

        disp('Finished!');
    end

    %% Part 9 - Iapp, Isyn, Isum

    %% Part 10 - Self Repairing plots
    if plotSR ~= 0
        disp('Started - plotSR');
        ssi = setsizee(plotSR);
        figure(); ssi();
        subplot(411);
        hold on;
        plotSecAreas(model, params.step, [-1000, 1000]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.AG(neurInd, :) * params.k_DSE;
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('DSE');
        ylim([1.1 * miny, 0.8 * maxy + eps]);
        xlim(vectime);
        subplot(412);
        hold on;
        plotSecAreas(model, params.step, [-1000, 1000]);
        miny = 0; maxy = 0;
        
        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.eSP_expand_line(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            h = plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :));
            h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end

        ylabel('eSP Line');
        ylim([0.8 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        ax = gca; ax.YGrid = 'on';
        lgd = legend;
        title(lgd, 'Astrocytes(j,k)');
        subplot(413);
        hold on;
        plotSecAreas(model, params.step, [-1000, 1000]);
        miny = 1; maxy = 1;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.BoF(neurInd, 1:(end - 2));
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time(1:(end - 2)), siGnal(tline(1:(end - 2))), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        lgd = legend;
        title(lgd, 'Neurons(m,n)');
        ylabel('BoF');
        ylim([0.9 * miny, 1.1 * maxy + eps]);
        xlim(vectime);
        subplot(414);
        hold on;
        plotSecAreas(model, params.step, [-0.2, 1.2]);
        miny = 0; maxy = 0;

        for k = 1:size(numofNeuro, 1)
            neurInd = sub2ind([params.mneuro, params.nneuro], numofNeuro(k, 1), numofNeuro(k, 2));
            siGnal = model.I_SR(neurInd, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(Time, siGnal(tline), linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 1, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', ['[', num2str(numofNeuro(k, 1)), ', ', num2str(numofNeuro(k, 2)), ']']);
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('I_{SR}');
        ylim([1.1 * miny, 1.1 * maxy + eps]);
        xlim(vectime);

        disp('Finished!');
    end

    %% Part 11 - SoI

    %% Part 12 - G WM

    %% Part 13 - Accuracy
    if plotAccuracy ~= 0
        disp('Started - plotAccuracy');
        ssi = setsizee(plotAccuracy);
        figure(); ssi();
        hold on;
        plotSecAreas(model, params.step, [-200, 200]);
        miny = 0.5; maxy = 1;
        [accurac, tLi] = accuracy(params, model);

        for k = 1:length(params.learn_order)
            siGnal = accurac(k, :);
            miny = min([siGnal, miny]); maxy = max([siGnal, maxy]);
            plot(tLi * params.step, siGnal, linestyle{rem(k - 1, nols) + 1}, ...
                'Linewidth', 0.5, ...
                'color', clrs(rem(k - 1, noc) + 1, :), ...
                'DisplayName', num2str(k));
        end

        ax = gca; ax.YGrid = 'on';
        ylabel('Accuracy');
        ylim([0.95 * miny, 1]);
        xlim(vectime);
        ax = gca; ax.YGrid = 'on';
        lgd = legend;
        title(lgd, 'image');
        xlabel('Time (s)');
        disp('Finished!');
    end

    %% Part 14 - I neuro astro
    if plotIneuroAstro ~= 0
        disp('Started - plotIneuroAstro');
        ssi = setsizee(plotIneuroAstro);

        HH = zeros(params.mastro * params.nastro, params.n);
        k = 1;

        for j = 1:params.nastro

            for i = 1:params.mastro
                HH(k, :) = reshape(model.Ineuro(i, j, :), [1, params.n]);
                k = k + 1;
            end

        end

        BBC = HH(:, tline);
        figure(); ssi();
        plot(0, 0); hold on;
        colrs = opt.colrs14;
        locs = opt.locs14;
        cmap = makeGradient(2, colrs, locs, 0);
        cmap = jet(256);
        imagesc(BBC);
        colormap(cmap);
        colorbar;

        if opt.limits14
            caxis(opt.limits14);
        end

        plotSecLines(model, 1, [0, size(BBC, 1) + 1]);
        xlabel('Time (s)');
        ylabel('Astrocytes');
        title('I Neuro Astro');
        xlim(vectimen);
        ylim([0.5, params.mastro * params.nastro + 0.5]);
        disp('Finished!');
    end

    %% Part 15 - I SR
    if plotI_SR ~= 0
        disp('Started - plotI_SR');
        ssi = setsizee(plotI_SR);

        BBC = model.I_SR;
        BBC = BBC(:, tline);
        figure(); ssi();
        plot(0, 0); hold on;
        colrs = opt.colrs15;
        locs = opt.locs15;
        cmap = makeGradient(256, colrs, locs, 0);
        imagesc(BBC);
        colormap(cmap);
        colorbar;

        if opt.limits15
            caxis(opt.limits15);
        end

        im = image(damage);
        im.AlphaData = backOpacity;
        clear PIC;
        plotSecLines(model, 1, [0, size(BBC, 1) + 1]);
        xlabel('Time (s)');
        ylabel('Astrocytes');
        title('I SR');
        xlim(vectimen);
        ylim([0.5, params.mneuro * params.nneuro + 0.5]);
        disp('Finished!');
    end
    
    %% Part 16 - Gli_global
    if plotGli_global ~= 0
        disp('Started - plotGli_global');
        ssi = setsizee(plotGli_global);

        HH = zeros(params.mastro * params.nastro, params.n);
        k = 1;

        for j = 1:params.nastro

            for i = 1:params.mastro
                HH(k, :) = reshape(model.Gli_global(i, j, 1:params.n), [1, params.n]);
                k = k + 1;
            end

        end

        BBC = HH(:, tline);
        figure(); ssi();
        plot(0, 0); hold on;
        % colrs = opt.colrs12;
        % locs = opt.locs12;
        % cmap = makeGradient(2, colrs, locs, 0);
        imagesc(BBC);
        % colormap(cmap);
        colorbar;

        if opt.limits12
            caxis(opt.limits12);
        end

        plotSecLines(model, 1, [0, size(BBC, 1) + 1]);
        xlabel('Time (s)');
        ylabel('Astrocytes');
        title('Gli global (whole-cell)');
        xlim(vectimen);
        ylim([0.5, params.mastro * params.nastro + 0.5]);
        disp('Finished!');
    end


    ress = 1;
end

function ssi = setsizee(mode)

    switch mode
        case 1
            ssi = @(t) set(gcf, 'Position', [100, 100, 800, 500]);
        case 2
            ssi = @(t) set(gcf, 'Position', [100, 100, 700, 250]);
        case 3
            ssi = @(t) set(gcf, 'Position', [100, 100, 800, 300]);
        case 4
            ssi = @(t) set(gcf, 'Position', [100, 100, 800, 200]);
        otherwise
            ssi = @(t) set(gcf, 'Position', [0, 0, 3000, 3000]);
    end

end

function plotSecLines(model, timescalse, ampl)
    h1 = double(model.T_Iapp(:));

    for i = 1:length(h1)
        timeee = [h1(i) * timescalse, h1(i) * timescalse + timescalse];
        h = plot(timeee, ampl, 'k:');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end

end

function plotSecAreas(model, timescalse, ampl)
    h1 = double(model.T_Iapp);

    for i = 1:size(h1, 1)
        timeee = [h1(i, 1) * timescalse, h1(i, 1) * timescalse + timescalse, ...
                      h1(i, 2) * timescalse, h1(i, 2) * timescalse + timescalse];
        h = area(timeee, [ampl(1), ampl(2), ampl(2), ampl(1)], ...
            'FaceColor', [0.96, 0.96, 0.96], ...
            'EdgeColor', [0.86, 0.86, 0.86], ...
            'LineStyle', '-.', ...
            'LineWidth', 0.7, ...
            'basevalue', -1000);
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end

end

% function PPo = scaleMap(HH)
%     rsip = size(HH,1)/size(HH,2);
%     nor  = floor(0.1/rsip);
%     PP   = zeros(size(HH,1)*nor, size(HH,2));
%     k    = 1;
%     for i = 1:size(HH,1)
%         for j = 1:nor
%             PP(k,:) = HH(i,:);
%             k = k + 1;
%         end
%     end
%     PPo = PP;
% end

function out = makeImage(HH, MAPcolor1)
    out(:, :, 3) = HH * MAPcolor1(3); %G
    out(:, :, 2) = HH * MAPcolor1(2); %R
    out(:, :, 1) = HH * MAPcolor1(1); %B
end

function pic = damageBackground(dat, noTime)
    dat = dat(:);
    pic = repmat(dat, 1, noTime);
end
