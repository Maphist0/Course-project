%TEST_ALL
%   Test all pre-processed in folder 'split_data'
%
%  Author:   Z.P. Zhang
%  Version:  0.1
%  Contact:  zhangz-z-p@sjtu.edu.cn
%
%  All rights reserved.
%

function test_all(config)

    VISUALIZE = config.visualize;

    root = config.root;
    data_folder = [root '/data/split_data/'];
    imgs = dir([data_folder 'BID']);

    % Initialize caffe network
    [net, mval] = initialize_fine_grained(config);

    % Load company ids obtained from international shipping container website
    cids = load([root '/model/bic-names.mat']);
    cids = cids.names;

    % Save the result
    save_results = {};

    for i = 3:numel(imgs)
        
        % File names
        fname = imgs(i).name;
        BID = [data_folder 'BID/' fname];
        CID = [data_folder 'CID/' fname];
        BTY = [data_folder 'BTY/' fname];
        
        % Coarse response
        [cid, coarse_bid, bty] = ...
            get_coarse_result(CID, BID, BTY, cids, config);
        
        % Fine response
        [fine_bid, ~] = ...
            get_fine_result(BID, net, mval, config);
        
        % Combination
        combined_bid = ...
            combine_fine_coarse(cid, fine_bid, coarse_bid);
        
        % Save to list
        save_results = [save_results strcat(cid,',',bty,',',...
            coarse_bid,',',fine_bid,',',combined_bid)]; %#ok<AGROW>
        
        if VISUALIZE
            figure(1); subplot(3,3,2);
            title(sprintf('Fine: %s, Coarse: %s, Combined: %s',...
                fine_bid, coarse_bid, combined_bid));
            drawnow;
            pause;
        end
    end
    
    caffe.reset_all();
    save_results %#ok<NOPRT>
end
