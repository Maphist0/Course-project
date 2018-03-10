%CONVERT_CLASS_TO_DIGIT 
%   Convert the numerical result from AlexNet to the corresponding integer 
%       character
%
% Input:
%   class   -   The numerical result from AlexNet
% 
% Output:
%   c_class -   The integer character converted from numerical result
%               If invalid input, return empty character
%
% Notice:
%   According to doc, the input should follow:
%       1. 0-9 for check digits
%
%       2. 10-19 for normal digits
%
%       3. The rest for A-Z
%
%   Some tricks,
%       1. Convert 0-9 (originally for check digits) as normal digits
%
%       2. Convert 'O' as '0' 
%          (This is caused by resizing the thin image of digits to a 
%           square input of AlexNet)
%
%       3. Convert 'S' as '9'
%          (This rarely occurs, but may be converted since we only deal
%           with digits, no characters)
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function c_class = convert_class_to_digit(class)
    if 0 <= class && class <= 9
        c_class = int2str(class);
    elseif 10 <= class && class <= 19
        c_class = int2str(class-10);
    elseif class == 34 
        c_class = int2str(0);   % 'O'(Oh) and '0'
    elseif class == 38
        c_class = int2str(9);   % 'S' and '9'
    else
        c_class = '';
    end
end