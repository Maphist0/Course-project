%VALIDATE_CHECK_DIGIT
%   Calculate and check the ID of shipping box
%   From: https://en.wikipedia.org/wiki/ISO_6346
%
% Input:
%   cid     -   string containing both CID and BID
%
% Output:
%   valid   -   1 if check success, 0 otherwise
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function valid = validate_check_digit(cid)

    if strlength(cid) ~= 11
        error('Invalid string length to validate check digit: %d instead of 11', ...
            strlength(cid));
    end
    
    % Step 1 
    char2num = [10 12 13 14 15 16 17 18 19 20 21 23 24 ...
        25 26 27 28 29 30 31 32 34 35 36 37 38];
    % mask separating digits from numbers
    msk = logical([1 1 1 1 0 0 0 0 0 0 0]);  
    % letters to numbers conversion
    cid( msk) = char2num(cid( msk)-'A'+1);
    % digit characters to numbers conversion
    cid(~msk) = cid(~msk)-'1'+1;
    vec = double(cid);
    
    % Step 2
    num = sum(vec(1:10).* 2.^(0:9));
    
    % Step 3
    check_digit = mod(mod(num,11),10);
    valid = (check_digit==vec(11));
end