%TEST_BASELINE  Test the baseline of OCR project
%
%  Use C-RNN directly. [https://github.com/meijieru/crnn.pytorch]
%
%  The score is calculated by comparing character-by-character.
%
%  NOTICE: The python program from C-RNN need to be modified.
% 
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function test_baseline(config)

    root = config.root;
    data_folder = [root '/data/split_data/'];
    gt_file = [root '/data/ground_truth.csv'];
    py_file = [root '/data/rcnn_result.csv'];

    % Generate the python command
    % You only need to call once
    if 1
        BIDs = dir([data_folder 'BID']);
        fnames = [data_folder 'BID/' BIDs(3).name];
        for i = 4:numel(BIDs)
            fnames = [fnames ',' data_folder 'BID/' BIDs(i).name];
        end
        BTYs = dir([data_folder 'BTY']);
        for i = 3:numel(BTYs)
            fnames = [fnames ',' data_folder 'BTY/' BTYs(i).name];
        end
        CBIDs = dir([data_folder 'CBID']);
        for i = 3:numel(CBIDs)
            fnames = [fnames ',' data_folder 'CBID/' CBIDs(i).name];
        end
        CIDs = dir([data_folder 'CID']);
        for i = 3:numel(CIDs)
            fnames = [fnames ',' data_folder 'CID/' CIDs(i).name];
        end
        cmd = ['python crnn.pytorch/demo.py ' fnames]
        system(cmd);
    end

    % Read groundtruth
    fid = fopen(gt_file, 'r');
    gts = textscan(fid, '%s%s%s%s%s', 'delimiter', ',');
    fclose(fid);

    % Read result
    fid = fopen(py_file, 'r');
    results = textscan(fid, '%s%s%s', 'delimiter', ',');
    fclose(fid);

    % Check result
    costs = zeros([1 numel(results{1})]);
    
    for i = 1:numel(results{1})
    
        % Find the line of ground truth
        gt_id = find(strcmp(gts{1}, results{1}{i}));
        gt_id = gt_id(1);
        result = upper(results{3}{i});
        
        % Find the field in ground truth
        if strcmp(results{2}{i}, 'CID')
            gt = gts{3}{gt_id};
        elseif strcmp(results{2}{i}, 'BID')
            gt = gts{4}{gt_id};
        elseif strcmp(results{2}{i}, 'CBID')
            gt = gts{3}{gt_id};
        elseif strcmp(results{2}{i}, 'BTY')
            if strcmp(gts{2}{gt_id}, '2')
                gt = gts{4}{gt_id};
            else
                gt = gts{5}{gt_id};
            end
        end
        
        costs(i) = EditDist(result, gt);
        fprintf('%s,%s,%d\n', ...
            gt, upper(result), costs(i));
    end

    fprintf('Sum cost: %.3f\n', sum(costs, 2));
end