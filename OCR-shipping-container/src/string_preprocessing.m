%STRING_PREPROCESSING Pre-process the string
%   
%  Pre-process the string into two sub-images.
%
%  Separate container identification and company identification.
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function string_preprocessing(config)
    
    VISUALIZE = 0;

    root = config.root;
    data_folder = 'data/split_data/';

    % Create folders in ${split_folder}
    % if ~exist([split_folder 'CBID'], 'dir'), mkdir([split_folder 'CBID']); end

    % List all images
    CBIDs = dir([data_folder 'CBID']);

    for i = 3:numel(CBIDs)
        
        % Load source image
        filename = [data_folder 'CBID/' CBIDs(i).name];
        im = imread(filename);

        % Make the image larger
        im = imresize(im, 2, 'bicubic');
        
        if VISUALIZE
            % Visualize
            figure(1);
            subplot(2,3,1); imshow(im);
        end
        
        % Binarize
        BW = imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + imbinarize(im(:,:,3));

        % Erode the image. Works better than image open operation.
        se = strel('disk', 4);
        BW_once = imerode(BW, se);

        if VISUALIZE
            subplot(2,3,2); imshow(BW);
            subplot(2,3,3); imshow(BW_once);
        end

        % Calculate histogram
        x = 1:size(BW,2);
        blk_cnt = sum(BW,1);
        blk_cnt_once = sum(BW_once);

        % Separate the middle bar
        [im_l, im_r] = unsupervised_split(im, BW_once, blk_cnt_once);
        
        if VISUALIZE
            subplot(2,3,4); imshow(im_l);
            subplot(2,3,5); imshow(im_r);
            figure(2); plot(x, blk_cnt, x, blk_cnt_once); hold off
            drawnow;
            pause
        end
        
        % Save results
        if 1
            imwrite(im_l, [data_folder 'CID/' CBIDs(i).name]);
            imwrite(im_r, [data_folder 'BID/' CBIDs(i).name]);
        end
    end
end

%SUPERVISED_SPLIT
% Accept user's input as the separation point
%
% Store the separated images to:
%       ${split_folder}/CBID/${img_name}-l.png
%   and
%       ${split_folder}/CBID/${img_name}-r.png
%
%
% Input:
%   im              - the original image
%   split_folder    - folder name to save the cropped image
%                       recommend: 'split_data/'
%   img_name        - the name of current image
%                       recommend: CBIDs(i).name
%
function supervised_split(im, split_folder, img_name)

    % Accept user's input
    split_pos_left = str2num(input('pos_left? ','s'));
    split_pos_right = str2num(input('pos_right? ','s'));
    disp(' ');
    
    % Show the cropped image
    figure(3);
    subplot(1,2,1);
    imshow(im(:, 1:split_pos_left, :));
    subplot(1,2,2);
    imshow(im(:, split_pos_right:end, :));
    drawnow;
    
    % Save subimage
    imwrite(im(:,1:split_pos_left,:), ...
        [split_folder 'CBID/' strrep(img_name, '.', '-l.')]);
    imwrite(im(:,split_pos_right:end,:), ...
        [split_folder 'CBID/' strrep(img_name, '.', '-r.')]);
end

%UNSUPERVISED_SPLIT 
% Split the image from the middle bar
%
% Apply an algorithm and return the sub-image on the left side of the 
%   middle bar, and the sub-image on the right side of the middle bar.
%
% 
% Input:
%   im      - The image
%   BW      - The binary mask, recommend to apply an image erode or image 
%               open operation to denoise.
%   blk     - The counting of binary mask vertically
%
%
% Output:
%  im_l     - The sub-image on the left side of middle bar, supposed to be 
%               the company ID.
%  im_r     - The sub-image on the right side, supposed to be the box ID.
%
function [im_l, im_r] = unsupervised_split(im, BW, blk)

    % Assumption 1: The middle bar in binary mask will connect to both
    %   the ceiling and the ground of image.
    %
    % Based on: Well, the middle bar is much longer than the height of any
    %   word.
    %
    %
    % Assumption 2: The middle bar would appear at < 50% horizontally.
    %
    % Based on: There are 4 letters on the left size (company ID), while
    %   there are 6-7 letters on the right size (box ID + check digit).
    %
    % So, find the first high response on the binary map from top-left
    %   corner to the middle line, and from the middle line to the top-left
    %   corner would classify the basic range of the middle bar.
    %
    % If not found, usually due to low image quality, set the search point
    %   to 0.375 times width of the image. 
    % The parameter can be changed according to real-world situations.
    %
    half_width = round(0.5*size(BW,2));
    bar_l = find(BW(1,1:half_width), 1);
    bar_r = half_width - find(flip(BW(1,1:half_width),2), 1);
    if isempty(bar_l)
        bar_l = round(0.375*size(blk,2));
        bar_r = bar_l;
    end
    
    % Calculate and tune the range for the left side
    is_empty = 0;
    start = 0;
    finish = 0;
    while (blk(bar_l) == 0), bar_l = bar_l + 1; end
    for j = bar_l:-1:1
        if is_empty == 0 && blk(j) == 0
            is_empty = 1;
            start = j;
        elseif is_empty == 1 && blk(j) ~= 0
            finish = j;
            break;
        end
    end
    bar_l = round((start+finish)/2);
    
    % For the right side
    is_empty = 0;
    start = 0;
    finish = 0;
    while (blk(bar_r) == 0), bar_r = bar_r - 1; end
    for j = bar_r:size(blk,2)
        if is_empty == 0 && blk(j) == 0
            is_empty = 1;
            start = j;
        elseif is_empty == 1 && blk(j) ~= 0
            finish = j;
            break;
        end
    end
    bar_r = round((start+finish)/2);
    
    % Crop the image according to the position above
    im_l = im(:, 1:bar_l, :);
    im_r = im(:, bar_r:size(blk,2), :);
end