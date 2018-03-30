%SPLIT_DIGITS_MSER
%   Split the sub-image containing digits by MSER method
%
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function [splits, splits_l, splits_r] = split_digits_MSER(im, config)

    VISUALIZE = config.visualize;
    
    splits = {};
    splits_l = {};
    splits_r = {};
    I = rgb2gray(im);
    
    % Detect MSER regions.
    [mserRegions, mserConnComp] = detectMSERFeatures(I, ...
        'RegionAreaRange',[20 8000],'ThresholdDelta',1);
    
    if 0
        figure(5); subplot(2,2,1); imshow(I); hold on;
        plot(mserRegions, 'showPixelList', true,'showEllipses',false)
        title('MSER regions')
        hold off
    end
    
    % Use regionprops to measure MSER properties
    mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
        'Solidity', 'Extent', 'Euler', 'Image');

    % Compute the aspect ratio using bounding box data.
    bbox = vertcat(mserStats.BoundingBox);
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;

    % Threshold the data to determine which regions to remove. These thresholds
    % may need to be tuned for other images.
    filterIdx = aspectRatio' > 3;
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

    % Remove regions
    mserStats(filterIdx) = [];
    mserRegions(filterIdx) = [];

    if 0
        % Show remaining regions
        figure(5); subplot(2,2,2); imshow(I); hold on;
        plot(mserRegions, 'showPixelList', true,'showEllipses',false)
        title('After Removing Non-Text Regions Based On Geometric Properties')
        hold off
    end

    % Get a binary image of the a region, and pad it to avoid boundary effects
    % during the stroke width computation.
    regionImage = mserStats(6).Image;
    regionImage = padarray(regionImage, [1 1]);

    % Compute the stroke width image.
    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);

    strokeWidthImage = distanceImage;
    strokeWidthImage(~skeletonImage) = 0;
    
    % Compute the stroke width variation metric
    strokeWidthValues = distanceImage(skeletonImage);
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    
    % Threshold the stroke width variation metric
    strokeWidthThreshold = 0.2; % 0.4
    strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;
    
    % Process the remaining regions
    for j = 1:numel(mserStats)

        regionImage = mserStats(j).Image;
        regionImage = padarray(regionImage, [1 1], 0);

        distanceImage = bwdist(~regionImage);
        skeletonImage = bwmorph(regionImage, 'thin', inf);

        strokeWidthValues = distanceImage(skeletonImage);

        strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

        strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

    end

    % Remove regions based on the stroke width variation
    mserRegions(strokeWidthFilterIdx) = [];
    mserStats(strokeWidthFilterIdx) = [];
    
    % Get bounding boxes for all the regions
    bboxes = vertcat(mserStats.BoundingBox);

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;

    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.02;
    xmin = (1-expansionAmount) * xmin;
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;

    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));
    ymax = min(ymax, size(I,1));

    % Show the expanded bounding boxes
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    filteredBBoxes = zeros([size(expandedBBoxes,1) 4]);
    line = 1;
    
    % Exclude bbox if height is too short
    height_thres = [0.6 0.9];
    width_thres = 0.25;
    IExpandedBBoxes = im;
    for i = 1:size(expandedBBoxes,1)
        if height_thres(1) * size(im,1) < expandedBBoxes(i, 4) && ...
                expandedBBoxes(i, 4) < height_thres(2) * size(im,1) && ...
                expandedBBoxes(i, 3) < width_thres * size(im,2)
            IExpandedBBoxes = insertShape(IExpandedBBoxes,'Rectangle',...
                expandedBBoxes(i,:),'LineWidth',1);
            filteredBBoxes(line,:) = expandedBBoxes(i,:);
            line = line + 1;
        end
    end
    filteredBBoxes = filteredBBoxes(1:line-1,:);
    
    if 0
        figure(5); subplot(2,2,3);
        imshow(insertShape(IExpandedBBoxes,'Rectangle',...
            expandedBBoxes,'LineWidth',1))
        title('Expanded Bounding Boxes Text')
    end
    
    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(filteredBBoxes, filteredBBoxes, 'Min');

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1);
    overlapRatio(1:n+1:n^2) = 0;
    
    % NMS
    [~, sorted_indices] = sort(filteredBBoxes(:,1));
    suppressed_bboxes_ids = zeros([1 size(filteredBBoxes,1)]);
    cnt_id = 1;
    cnt_suppressed = 1;
    overlap_thres = 0.7;
    
    while sum(sorted_indices) > 0
        
        if sorted_indices(cnt_id) == 0
            cnt_id = cnt_id + 1;
            continue;
        end
        
        id = sorted_indices(cnt_id);
        sorted_indices(cnt_id) = 0;
        cnt_id = cnt_id + 1;
        
        suppressed_bboxes_ids(cnt_suppressed) = id;
        cnt_suppressed = cnt_suppressed + 1;
        
        high_overlap_bbox = find(overlapRatio(id,:)>overlap_thres);
        for i = 1:length(high_overlap_bbox)
            sorted_indices(find(sorted_indices==high_overlap_bbox(i),1)) = 0;
        end
    end
    
    suppressed_bboxes_ids = suppressed_bboxes_ids(1:find(suppressed_bboxes_ids==0,1)-1);
    suppressed_bboxes = filteredBBoxes(suppressed_bboxes_ids,:);
    
    if VISUALIZE
        SuppressedBBoxes = insertShape(im,'Rectangle',suppressed_bboxes,'LineWidth',1);
        figure(1); subplot(3,3,7);
        imshow(SuppressedBBoxes);
        title('Segmentation by MSER');
    end
end