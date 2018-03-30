%GET_COARSE_RESULT
%   Generate the coarse result by CRNN
%
%   Refine the company identification result with international shipping 
%       container company list
%
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function [cid, bid, bty] = get_coarse_result(cid_fname, bid_fname, ...
        bty_fname, cids, config)

    % Visualize
    VISUALIZE = config.visualize;
    root = config.root;

    % Call RCNN to detect CID, BID, and BTY at the same time
    cmd = ['python crnn.pytorch/demo.py ' cid_fname ',' bid_fname ',' ...
        bty_fname];
    system(cmd);
    
    % Read result
    fid = fopen([root '/data/rcnn_result.csv'], 'r');
    results = textscan(fid, '%s%s%s', 'delimiter', ',');
    fclose(fid);
    data = results(3);
    cid = upper(data{1}{1});
    bid = data{1}{2};
    bty = upper(data{1}{3});
    
    % Trick, last character in company identification must be U
    cid(end) = 'U';
    
    % Trick, only limited types of box type id defined by ISO
    bty = ['4' bty(2) 'G1'];
    
    % Query CID in the dataset, find the cloest CID if not in the dataset.
    % Assume that the length of CID is 4.
    %
    % Calculate edit distance between CID and each entry in dataset
    distances = zeros([1 size(cids,2)]);
    for i = 1:size(cids, 2)
        distances(i) = EditDist(cid, char(cids(i)));
    end
    
    % Check if CID exists in the dataset
    find_id = find(distances == 0);
    if isempty(find_id), [~, find_id] = min(distances); end
    
    
    if VISUALIZE
        
        % Show company identification
        cid_im = imread(cid_fname);
        figure(1); subplot(3,3,1); imshow(cid_im);
        title(sprintf('RCNN company id: %s. From database: %s', ...
            cid, char(cids(find_id))));
        
        % Show box type identification
        bty_im = imread(bty_fname);
        subplot(3,3,3); imshow(bty_im);
        title(sprintf('RCNN box type: %s', bty));
    end
end