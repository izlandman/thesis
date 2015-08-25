% crunch numbers of details of the coefficients
% rows relate back to the coefficients, columns to the number of samples in
% the pool to compare to the target

% Early work at sorting out if modeling would be feasiable. Should have
% started with building GMMs instead of the babysteps into 

function [stats]=eegStatistics(target_data,pool_data,butter_order,...
    butter_low,butter_high,cc_num,analysis_frame,analysis_shift,...
    pre_emp_coef,range,banks,liftering_param,block_time,epoch_time)
if nargin == 2
    fltr.butter_order = 5;
    fltr.butter_low = 0.5;
    fltr.butter_high = 50;
    mf.cc_num = 13;
    % in milliseconds
    mf.analysis_frame = 1000;
    mf.analysis_shift = 500;
    mf.pre_emp_coef = 0.97;
    mf.range = [0.5 80];
    mf.banks = 21;
    mf.liftering_param = 22;
    % in seconds
    mf.block_time = 30;
    mf.epoch_time = 8;
else
    fltr.butter_order = butter_order;
    fltr.butter_low = butter_low;
    fltr.butter_high = butter_high;
    mf.cc_num = cc_num;
    % in milliseconds
    mf.analysis_frame = analysis_frame;
    mf.analysis_shift = analysis_shift;
    mf.pre_emp_coef = pre_emp_coef;
    mf.range = range;
    mf.banks = banks;
    mf.liftering_param = liftering_param;
    % in seconds
    mf.block_time = block_time;
    mf.epoch_time = epoch_time;
end

% read in the EDF data and setup filter
[target.labels,target.durations,target.data,target.sample_rate,target.duration] =...
    filePrep(target_data,fltr);

% break down into Block, Frame, Window, Epoch to build feature vectors
[target.features_full, target.features_block, target.features_epoch] =...
    blockFrameWindowEpoch(target,mf);

% verify means and stddevs of coefficients
[target_full_coefficient_stats] = meanAndStandardDev(target.features_full.CCs);
[target_block_coefficient_stats] = meanAndStandardDev(target.features_block.CCs);

% sort through pool to setup for file comparison
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_data,target_data,fltr);

% loop through each file so there aren't giant datasets sitting around in
% memory. probably not efficient for large data pools

pool_count = length(pool.data);
stats.pool_full_coefficients_stats = zeros(length(target.features_full.CCs{1}(:,1)),3,pool_count);
stats.pool_block_coefficients_stats = stats.pool_full_coefficients_stats;

for k=1:pool_count
    
    % break down into Block, Frame, Window, Epoch to build feature vectors
    data_vector.data = pool.data{k};
    data_vector.sample_rate = pool.sample_rate(k);
    data_vector.duration = pool.duration(k);
    [features_full, features_block, features_epoch] = blockFrameWindowEpoch(data_vector,mf);
    
    % build stats on each file
    stats.pool_full_coefficients_stats(:,:,k) = meanAndStandardDev(features_full.CCs);
    stats.pool_block_coefficients_stats(:,:,k) = meanAndStandardDev(features_block.CCs);
    
end

stats.comparable_full_mean = abs(squeeze(bsxfun(@minus,...
    stats.pool_full_coefficients_stats(:,1,:),target_full_coefficient_stats(:,1))));
stats.comparable_block_mean = abs(squeeze(bsxfun(@minus,...
    stats.pool_block_coefficients_stats(:,1,:),target_block_coefficient_stats(:,1))));

end