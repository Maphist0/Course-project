%GET_FINE_RESULT
%   Get the fine-grained result based on character segmentation and
%   Alexnet
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function [bid, bid_conf] = get_fine_result(bid_fname, net, mval, config)

    VISUALIZE = config.visualize;

    % Load the source image
    im = imread(bid_fname);
    im = imresize(im, 2);
    
    % Convert to binary image with adaptive thresholding
    BW = logical(imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + ...
        imbinarize(im(:,:,3)));
    
    % Special case for black and white inverse
    if sum(sum(BW, 1)) > 0.5 * size(BW,1) * size(BW, 2)
        BW = 1 - BW;
    end
    
    % Eliminate noise points 
    se = strel('disk', 2);
    BW_once = imerode(BW, se);
    
    % Calculate histogram
    x = 1:size(BW,2);
    histogram = sum(BW,1);
    histogram_erode = sum(BW_once);
    
    if VISUALIZE
        figure(1); subplot(3,3,2); imshow(im);
        subplot(3,3,4); imshow(BW); title('Binarized box id image');
        subplot(3,3,5); imshow(BW_once); title('Binarized and eroded box id image');
        figure(2); plot(x, histogram, x, histogram_erode);
        figure(3); clf;
    end

    % Split characters by histogram
    [splits, splits_l, splits_r] = ...
        split_digits_histogram(im, histogram_erode, config);
    
    % Split characters by MSER
%     [splits, splits_l, splits_r] = ...
%         split_digits_MSER(im, config);
    
    % Fine-grained result and the confidence for each character
    alex_string = '';
    alex_string_conf = '';
    
    for i = 1:min(numel(splits), 12)

        % Get the response of Alexnet
        % Resize to Alexnet's input size
        digit = imresize(splits{i}, [227 227]);
        [response, class] = get_caffe_score(digit, net, mval);

        if VISUALIZE
            % Show the cropped image
            figure(3); subplot(2,6,i); imshow(splits{i});
            title(sprintf('%d - %.3f', class, response));
        end

        class_digit = convert_class_to_digit(class);
        
        if ~isempty(length(class_digit))
            alex_string = [alex_string class_digit];
            alex_string_conf = [alex_string_conf response];
        end

        if VISUALIZE
            % Plot separation lines
            x_one = ones([1 size(im,1)]);
            x_l = splits_l{i}*x_one;
            x_r = splits_r{i}*x_one;
            y = 1:size(im,1);
            figure(2); hold on; 
            line(x_l, y, 'Color', 'black');
            line(x_r, y, 'Color', 'red'); 
            hold off;
        end
    end
    
    bid = alex_string;
    bid_conf = alex_string_conf;
end