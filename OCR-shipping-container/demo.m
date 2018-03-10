addpath(genpath('./'));

root = pwd;
config.root = root;
config.visualize = 1;
config.caffe_root = [root '/caffe'];

% Only use it when you want to generate split data from source data by yourself.
%
% parse_source_data(config);
%
% Pre-process the sub-image, split company identification and box identification.
% string_preprocessing(config);

% Use the following line to test the coarse grained baseline (CRNN directly)
% Remember to edit the root path in './crnn.pytorch/demo.py'.
%
% test_baseline(config);

test_all(config);
