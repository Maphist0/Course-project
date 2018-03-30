%SPLIT_DIGITS_HISTOGRAM
%   Split BID into each digits with the help of histogram
%
% Input:
%   im      -   The input BID image
%   blk_cnt -   The count of black pixels 
%
% Output:
%   splits      -   A list containing all segmented digits
%   splits_l    -   A list containing the left position of all segmentations
%   splits_r    -   A list containing the right position of all segmentations
%
%
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function [splits, splits_l, splits_r] = split_digits_histogram(im, blk_cnt, config)

    VISUALIZE = config.visualize;

    % Prepare variables
    width = size(im, 2);
    left = 1;
    is_blk = 0;
    blk_thres = 2;
    margin = 2;
    splits = {};
    splits_l = {};
    splits_r = {};
    
    % For visualization
    im_with_bbox = im;
    
    for i = 1:width
        
        if is_blk == 0 && blk_cnt(i) > blk_thres
        
            is_blk = 1;
            left = i-1;
        
        elseif is_blk == 1 && blk_cnt(i) <= blk_thres
            
            is_blk = 0;
            right = i;
            
            % Segment the image
            splits = [splits im(:, max(left-margin,1):min(right+margin,width), :)];
            splits_l = [splits_l left];
            splits_r = [splits_r right];
            
            % Annotate the segmentation on the image
            im_with_bbox = insertShape(im_with_bbox,'Rectangle',...
                [left 1 right-left+1 size(im,1)],'LineWidth',3);
        
        end
    end
    
    % The last part, need special operation
    if is_blk == 1
        
        right = width;
        splits = [splits im(:, max(left-margin,1):min(right+margin,width), :)];
        splits_l = [splits_l left];
        splits_r = [splits_r right];
        
    end
    
    if VISUALIZE
        figure(1); subplot(3,3,6); imshow(im_with_bbox); 
        title('Segmentation by histogram');
    end
end