%GET_CAFFE_SCORE
%   Forward AlexNet with a given image for a single digit
% 
% Input:
%   data        -   Cropped image for a single digit
%   net         -   AlexNet loaded by MatCaffe
%   mval        -   1 x 3 vector for mean color value of [R G B] in 'single'
%                       precision
% Output:
%   response    -   The maximum response from AlexNet
%   class       -   The id of maximum response
%                   Check '../util/convert_class_to_digit.m' for more
%
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function [response, class] = get_caffe_score(data, net, mval)
    % To single
    data = single(data);
    % BGR format
    data = data(:,:,[3 2 1]);
    % Mean substraction
    for ch=1:3
        data(:,:,ch) = data(:,:,ch) - mval(:,:,ch);
    end
    % Permute width and height (Caffe thing)
    data = permute(data, [2, 1, 3]);
    % Forward
    res = net.forward({data});
    prob = res{1};
    [response, class] = max(prob);
    % Decode class id
    % Right now do nothing for English characters
    class = class - 1;
end