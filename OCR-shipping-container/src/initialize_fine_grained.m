%INITIALIZE_FINE_GRAINED
%  Initialize the caffe network for fine-grained stream
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function [net, mval] = initialize_fine_grained(config)

    root = config.root;
    caffe_root = config.caffe_root;
    
    % Load the AlexNet network
    addpath(caffe_root);
    model = [root '/model/deploy.prototxt'];
    weights = [root '/model/exVersion_iter_30000.caffemodel'];
    gpuDevice([]);
    caffe.reset_all();
    caffe.set_mode_gpu()
    caffe.set_device(0);
    net = caffe.Net(model, weights, 'test');
    
    % Load mean image data
    mval = zeros([227 227 3]);
    for ch=1:3
        mval_ = csvread(sprintf('%s/model/mean_%d.csv', root, ch-1));
        mval(:,:,ch) = single(mval_(:, 1:end-1));
    end
end