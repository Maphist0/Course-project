%PARSE_SOURCE_DATA  Parse all image files into four categories
%
%   1. Company ID only
%       - type_name: CID
%       - 4 ASCII characters
%
%   2. Company ID + Box ID
%       - type_name: CBID
%       - 4 ASCII characters with 6/7 digits
%
%   3. Box ID only
%       - type_name: BID
%       - 6/7 digits
%
%   4. Box Type
%       - type_name: BTY
%       - 4 ASCII characters
%
%  Save cropped image in './data/split_data/${TYPE_NAME}'
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

function parse_source_data(config)

    VISUALIZE = 1;  % Show the intermediate image
    W_GT = 0;       % Write to ground_truth.csv file
    
    root = config.root;
    
    source_data_dir = [root '/data/labels/'];
    assert(exist(source_data_dir, 'dir') == 7, ...
        'Could not find source data in "%s". Please refer to README.md.', ...
        source_data_dir);
    
    label_path = [root '/data/labels/boxlabel/'];
    img_path = [root '/data/labels/testset/'];
    save_path = [root '/data/split_data/'];
    gt_file = [root '/data/ground_truth.csv'];
    
    % Create folders in 'save_path'
    if ~exist([save_path 'CID'], 'dir'), mkdir([save_path 'CID']); end
    if ~exist([save_path 'CBID'], 'dir'), mkdir([save_path 'CBID']); end
    if ~exist([save_path 'BID'], 'dir'), mkdir([save_path 'BID']); end
    if ~exist([save_path 'BTY'], 'dir'), mkdir([save_path 'BTY']); end

    % Parse all XML files for images
    labels = dir(label_path);
    if W_GT, gt = cell(1, numel(labels)-2); end
    
    fprintf('Please input the ground truth value for different parts');
    fprintf(' according to the prompt.\n');
    
    for i = 3:numel(labels)
        
        label = [label_path labels(i).name];
        label = parseXML(label);

        % Extract useful information
        %   image's filename
        img_name = label.Children(4).Children.Data;
        %   bbox
        bboxes = {};
        
        for j = 14:2:numel(label.Children)
            bboxes = [bboxes get_bbox(label, j)];
        end

        % Process image
        im = imread([img_path img_name]);
        
        if numel(bboxes) == 3
            
            % Crop image
            CID = im(bboxes{1}(2):bboxes{1}(4), bboxes{1}(1):bboxes{1}(3), :);
            BID = im(bboxes{2}(2):bboxes{2}(4), bboxes{2}(1):bboxes{2}(3), :);
            BTY = im(bboxes{3}(2):bboxes{3}(4), bboxes{3}(1):bboxes{3}(3), :);
            
            if VISUALIZE
                figure(1);
                subplot(1,4,1); imshow(im);  title 'Image';
                subplot(1,4,2); imshow(CID); title 'Company ID';
                subplot(1,4,3); imshow(BID); title 'Box ID';
                subplot(1,4,4); imshow(BTY); title 'Box type';
                drawnow;
            end

            if W_GT
                % Get user input
                gt_CID = ''; gt_BID = ''; gt_BTY = '';
                while isempty(gt_CID), gt_CID = upper(input('CID? ','s')); end
                while isempty(gt_BID), gt_BID = upper(input('BID? ','s')); end
                while isempty(gt_BTY), gt_BTY = upper(input('BTY? ','s')); end

                % Save to ground truth
                gt{i-2} = sprintf('%s,%d,%s,%s,%s\n', img_name, 3, gt_CID, ...
                    gt_BID, gt_BTY);
            end

            % Save cropped image
            imwrite(CID, [save_path 'CID/' img_name]);
            imwrite(BID, [save_path 'BID/' img_name]);
            imwrite(BTY, [save_path 'BTY/' img_name]);

        elseif numel(bboxes) == 2

            CBID = im(bboxes{1}(2):bboxes{1}(4), bboxes{1}(1):bboxes{1}(3), :);
            BTY  = im(bboxes{2}(2):bboxes{2}(4), bboxes{2}(1):bboxes{2}(3), :);
            
            if VISUALIZE
                figure(1);
                subplot(1,3,1); imshow(im);   title 'Image';
                subplot(1,3,2); imshow(CBID); title 'Company ID + Box ID';
                subplot(1,3,3); imshow(BTY);  title 'Box type';
                drawnow;
            end

            if W_GT
                % Get user input
                gt_CBID = ''; gt_BTY = '';
                while isempty(gt_CBID), gt_CBID = upper(input('CBID? ','s')); end
                while isempty(gt_BTY), gt_BTY = upper(input('BTY? ','s')); end

                % Save to ground truth
                gt{i-2} = sprintf('%s,%d,%s,%s,\n',img_name,2,gt_CBID,gt_BTY);
            end
                
            % Save cropped image
            imwrite(CBID, [save_path 'CBID/' img_name]);
            imwrite(BTY, [save_path 'BTY/' img_name]);
            
        else
            
            error('Invalid bbox');
        
        end
    end

    if W_GT
        fprintf('Writting ground truth values to %s ...\n', gt_file);
        fid = fopen(gt_file, 'w');
        for i = 1:numel(gt)
            fprintf(fid, char(gt{i}));
        end
        fclose(fid);
    end
end

function bbox = get_bbox(label, XML_pos)

    bbox_label = label.Children(XML_pos).Children(10);
    bbox = zeros([4 1]);

    for i = 1:4
        bbox(i) = str2num(bbox_label.Children(2*i).Children.Data);
    end
end