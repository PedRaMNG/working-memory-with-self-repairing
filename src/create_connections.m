function [Post_line, Pre] = create_connections()

    params       = model_parameters();
    % 3D connection of neurons and synaptic connections
    Post         = zeros(params.mneuro, params.nneuro, params.N_connections, 'int16');
    Post_for_one = zeros(params.mneuro, params.nneuro,'int8'); %why do we need this one?
    ties_stock   = 1000 * params.N_connections; %what's ties?
    
    for i = 1 : params.mneuro
        for j = 1 : params.nneuro
            %[samples] = fast_weighted_sampling(weights, m);
            
            XY      = zeros(2, ties_stock, 'int8');
            R       = random('exp', params.lambda, 1, ties_stock);
            fi      = 2 * pi * rand(1, ties_stock);
            XY(1,:) = fix(R .* cos(fi));
            XY(2,:) = fix(R .* sin(fi));
            XY1     = unique(XY', 'row','stable'); %returns the same data with no repetition 
            XY      = XY1';
            n       = 1;
            
            for k = 1:ties_stock
                x = i + XY(1, k);
                y = j + XY(2, k);
                if (i == x && j == y)
                    pp = 1; % This is distance condition, with sin and cos we applied a distance condition and
                else
                    pp = 0; % this line will evaluate that
                end
                if (x > 0 && y > 0 && x <= params.mneuro && y <= params.nneuro && pp == 0)
                    % returns the linear index equivalents to the rows(x) and columns(y). what does it mean?
                    Post(i,j,n) = sub2ind(size(Post_for_one), x, y);
                    n = n + 1;
                end
                if n > params.N_connections
                    break
                end
            end
        end
    end
    Post2 = permute(Post, [3 1 2]); %what's going on in here?
    Post_line = Post2(:)';
    Pre = zeros(1,size(Post_line, 2), 'int16');
    k = 1;
    for i = 1 : params.N_connections : size(Post_line, 2)
        Pre(i : i + params.N_connections - 1) = k;
        k = k + 1;
    end
end

function [samples] = fast_weighted_sampling(weights, m)
    % std::pow(dist(gen), 1. / iter)
    q = pow(rand(length(weights), 1), 1 ./ weights);
    [~, samples] = sort(q);
    samples = samples(1:m);
end

function get_sub_weights(weights, i, j, w, h)
    weights()
end

function [weights] = make_weights(w, h) % what does this function do?
    weights = zeros(2 * w + 1, 2 * h + 1, 'double');
    for i = -w:w
        for j = -h:h
            weight = exp(-norm([i, j]) * params.lambda) * params.lambda;
            weights(i + w + 1, j + h + 1) = weight;
        end
    end
end
