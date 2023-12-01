function [images, Tumor] = load_images(Pattern)
    
    switch Pattern
        case 1
            images_dir = '../images - 79';
            image_names = {
                'zero.jpg',     ...  % 0
                'one.jpg',      ...  % 1
                'two.jpg',      ...  % 2
                'three.jpg',    ...  % 3
                'four.jpg',     ...  % 4
                'five.jpg',     ...  % 5
                'six.jpg',      ...  % 6
                'seven.jpg',    ...  % 7
                'eight.jpg',    ...  % 8
                'nine.jpg'      ...  % 9
            };
        case 2
            images_dir = '../images - strips';
            image_names = {
                'strip1.jpg',       ...  % 0
                'strip2.jpg',       ...  % 1
            };
    end

    images = {};
    for name = image_names
        image = imread(fullfile(images_dir, name{1}));
        image = rgb2gray(image);
        images{end + 1} = image;
    end
        
    if Pattern == 1
        Tumor = imread(fullfile(images_dir, 'Damage_705530.jpg')); % Discrete damage
        Tumor = rgb2gray(Tumor);
    else 
        Tumor = imread(fullfile(images_dir, 'Damage_continuous.jpg')); % Continuous damage
        Tumor = rgb2gray(Tumor);
    end
    
end
