function [ST, ST2] = impair(sel, n, params, Tumor, numofPost, Post)
    switch sel
        case 0
            ST    = ones(1, n);
            ST2 = ones(1, params.quantity_neurons);
        case 1
            numofper = floor(params.scenario1a2.probability * n);
            h1       = [params.scenario1a2.amplitude*ones(1, numofper), ones(1, n - numofper)];
            ST       = h1(randperm(n));
            ST2      = ones(1, params.quantity_neurons);
            count = 0;
            for i = 1:numel(numofPost)
                ST2(i) = sum(ST(count + (1:numofPost(i))))/numofPost(i);
                count = count + numofPost(i);
            end
        case 2
            numofper = floor(params.scenario1a2.probability * n);
            h1       = [(1-params.scenario1a2.amplitude)*rand(1, numofper) + params.scenario1a2.amplitude, ...
                         ones(1, n - numofper)];
            ST       = h1(randperm(n));
            numofper = floor(params.scenario1a2.probability * params.quantity_neurons);
            h1       = [(1-params.scenario1a2.amplitude)*rand(1, numofper) + params.scenario1a2.amplitude, ...
                         ones(1, params.quantity_neurons - numofper)];
            ST2         = h1(randperm(params.quantity_neurons));
        case 3
            ST = double(Post);
            tumVec = double(Tumor(:))/255;
            for i = 1:numel(tumVec)
                ST(ST==i) = tumVec(i);
            end
            ST2 = double(Tumor(:))'/255;
        case 31
            ST = double(Tumor(:))'/255;
            ST2 = ST;
    end
end
