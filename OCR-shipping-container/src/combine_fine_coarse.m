%COMBINE_FINE_COARSE
%   Combine the result of fine- and coarse-grained result
%
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function combined = combine_fine_coarse(cid, fine, coarse)

    combined = fine;

    if length(fine) == 7 && validate_check_digit(strcat(cid, fine))
        % Do nothing   
    elseif length(fine) > 6
        [combined, ~] = combine_alex_rcnn(fine, coarse, cid);
    end
end

function [combined, found] = combine_alex_rcnn(fine, coarse, CID)

    % A set of candidates for check digit
    check_digit_candidate = {};
    
    % Some parameters
    len_fine = length(fine);
    len_coarse = length(coarse);
    fine_digits = fine(1:6);
    len = min(len_fine, len_coarse);
    len = min(len, 6);
    
    % Indicating the position of digits that are different between alex 
    %   and rcnn results
    diff = zeros([1 6]);
    for i = 1:len
        if ~strcmp(fine(i),coarse(i)) && isstrprop(coarse(i),'digit')
            diff(i) = 1;
        end
    end
    
    % Generate a list of BID according to permutation
    digit_candidate = repmat(fine_digits,2^sum(diff),1);
    diff_ids = find(diff);
    for i = 1:sum(diff)
        diff_id = diff_ids(i);
        for j = 1:2^i:2^sum(diff)
            for k = 1:2^(i-1)
                digit_candidate(j+k-1,diff_id) = fine(diff_id);
                digit_candidate(j+2^(i-1)+k-1,diff_id) = coarse(diff_id);
            end
        end
    end
    
    % Append check digits into candidate set
    for i = 7:len_fine
        check_digit_candidate = [check_digit_candidate fine(i)]; %#ok<AGROW>
    end
    for i = 7:len_coarse
        check_digit_candidate = [check_digit_candidate coarse(i)]; %#ok<AGROW>
    end
    
    % Check for each combination
    found = 0;
    for i = 1:size(digit_candidate,1)
        if found, break; end
        for j = 1:numel(check_digit_candidate)
            if found, break; end
            test_bid = num2str(digit_candidate(i,:),'%d');
            test_str = strcat(CID, test_bid, check_digit_candidate{j});
            if validate_check_digit(test_str)
                found = 1;
                combined = [test_bid check_digit_candidate{j}]; 
            end
        end
    end
    
    % If failed to find, assign the original bid
    if ~found, combined = fine_digits; end
end