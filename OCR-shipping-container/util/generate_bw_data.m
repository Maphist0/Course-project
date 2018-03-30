%GENERATE_BW_DATA  Binarize all data images
%
%  The black & white images are stored in 'bw_data/',
%       with the same folder structure.
% 
%  Author:   Maphisto
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.

% Modify to your root path
root = '/home/${USER}/Desktop/OCR/';

data_folder = 'data/';
bw_data_folder = 'bw_data/';

% Create folders in './bw_data/'
if ~exist([bw_data_folder 'CID'], 'dir'), mkdir([bw_data_folder 'CID']); end
if ~exist([bw_data_folder 'CBID'], 'dir'), mkdir([bw_data_folder 'CBID']); end
if ~exist([bw_data_folder 'BID'], 'dir'), mkdir([bw_data_folder 'BID']); end
if ~exist([bw_data_folder 'BTY'], 'dir'), mkdir([bw_data_folder 'BTY']); end

BIDs = dir([data_folder 'BID']);
for i = 3:numel(BIDs)
    im = imread([root data_folder 'BID/' BIDs(i).name]);
    im = imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + imbinarize(im(:,:,3));
    imwrite(im, [root bw_data_folder 'BID/' BIDs(i).name])
end
BTYs = dir([data_folder 'BTY']);
for i = 3:numel(BTYs)
    im = imread([root data_folder 'BTY/' BTYs(i).name]);
    im = imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + imbinarize(im(:,:,3));
    imwrite(im, [root bw_data_folder 'BTY/' BTYs(i).name])
end
CBIDs = dir([data_folder 'CBID']);
for i = 3:numel(CBIDs)
    im = imread([root data_folder 'CBID/' CBIDs(i).name]);
    im = imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + imbinarize(im(:,:,3));
    imwrite(im, [root bw_data_folder 'CBID/' CBIDs(i).name])
end
CIDs = dir([data_folder 'CID']);
for i = 3:numel(CIDs)
    im = imread([root data_folder 'CID/' CIDs(i).name]);
    im = imbinarize(im(:,:,1)) + imbinarize(im(:,:,2)) + imbinarize(im(:,:,3));
    imwrite(im, [root bw_data_folder 'CID/' CIDs(i).name])
end