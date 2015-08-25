% eegCompare applies machine learning to match the TARGET file to those
% files found in the POOL directory. This reads all of the day everyime it
% operates and is super time intensive and resource intensive. it is OLD
% and should NOT BE USED.
%
% The process:
% 1 - read TARGET file and build feature vector
%   be sure to filter incoming data and trim out any non-data channels
% 2 - read in files from POOL to build their feature vectors
% 3 - compare TARGET to those in POOL via matching algorithm
% 4 - present results
%
% Feature Vectors: At the moment the focus will be on the strongest
% frequency band present at each sensor. Many studies have shown that
% changes within these bands is indicative of imagine motor control

% target is the selected EDF EEG, pool is a directory of EDF EEGs to be
% compared against target
function [distances] = eegCompare(target_data,pool_data,coeff_list,...
    butter_order,butter_low,butter_high,cc_num,analysis_frame,...
    analysis_shift,pre_emp_coef,range,banks,liftering_param,...
    block_time,epoch_time)
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
    coeff_list = 1:mf.cc_num;
elseif nargin == 3
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
    coeff_list = [];
end

% read in the EDF data and setup filter
[target.labels,target.durations,target.data,target.sample_rate,target.duration] =...
    filePrep(target_data,fltr,1);

% sort through pool to setup for file comparison
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_data,target_data,fltr,1);

% fourier transform to find dominant frequencies | concern over filtering
% window type/size
features = featureFinder(target.data,target.sample_rate,mf.block_time,mf.epoch_time);

% Frequency Band Powers
% for k=1:length(pool.data)
%     bands.pool(:,k) = featureFinder(pool.data{k},pool.sample_rate(k),...
%         mf.block_time, mf.epoch_time);
% end

% break down into Block, Frame, Window, Epoch to build feature vectors
[target.features_full, target.features_block, target.features_epoch] =...
    blockFrameWindowEpoch(target,mf);

% build GMM models of each channel from the signal data given
[target.GMM_full,target.GMM_block,target.GMM_epoch] = ...
    channelGmmModel(target);

% ------------------------------------------------------------- BAD IDEA
% try something trivial, just stack all the channels in time for SVM
% target_feature_vector = featureStacker(target_data);



% allow the user to select which coefficients are used in the distance
% measure perhaps? show them the stats and allow them to choose

if( isempty(coeff_list) == 1 )
    coeff_prompt = 'Specificy coefficients to compare. Use [ ] please. \n';
    coeff_list = input(coeff_prompt);
    if( isempty(coeff_list) == 1 )
        coeff_list = 1:mf.cc_num;
    end
end

% MEL-CoEff Calculations
distances = mahalDistance(pool,target,mf,coeff_list);
full_distance_sum = sum(cell2mat(distances.full),2);
distances.full_normalized = 1./( full_distance_sum / min(full_distance_sum) );
% what to do with the block cells?
end

% the rows returned correspond to the target, the columns correspond to the
% pool file. if the target has four blocks, then distances will be (4 by j)
% where j is the number of blocks in each pool file
function mal_distances = mahalDistance(pool,target,mf,coeff_list)

pool_count = length(pool.data);
pool_features.full = cell(1,pool_count);
pool_features.block = cell(1,pool_count);
pool_features.epoch = cell(1,pool_count);
channel_count = length(pool.data{1}(:,1));

for k=1:pool_count
    
    % break down into Block, Frame, Window, Epoch to build feature vectors
    data_vector.data = pool.data{k};
    data_vector.sample_rate = pool.sample_rate(k);
    data_vector.duration = pool.duration(k);
    [gmModel.features_full, gmModel.features_block, gmModel.features_epoch] = blockFrameWindowEpoch(data_vector,mf);
    
    [pool_features.full{k},pool_features.block{k},pool_features.epoch{k}] = ...
        channelGmmModel(gmModel);
    
    % compare pool blocks to target blocks, channel to channel
    for d=1:channel_count
        mal_distances.block{k,d} = malBlockCompare(target.GMM_block,pool_features.block{k},d,coeff_list);
        mal_distances.full{k,d} = malBlockCompare(target.GMM_full,pool_features.full{k},d,coeff_list);
    end
    
end

end

% compute mal distances between gmm block data, match TARGET to POOL
function distances = malBlockCompare(target,pool,channel,coeff_list)
[target_blocks,q] = size(target);
[pool_blocks,q] = size(pool);
dimensions = target{1}.NDimensions;
target_blocks_mat = zeros(target_blocks,dimensions);
distances = zeros(target_blocks,pool_blocks);

for k=1:target_blocks
    target_blocks_mat(k,:) = target{k,channel}.mu;
end
for r=1:pool_blocks
    % not enough points to us mahal distance this way
    % distances(:,r) = mahal(pool{r,channel}.mu(coeff_list),target_blocks_mat(:,coeff_list));
    % try using pdist(x,'chebychev') instead for now, distances to target
    % are the first n, n where is the number of rows in target_blocks_mat,
    % of the results D
    D = pdist([pool{r,channel}.mu(coeff_list);target_blocks_mat(:,coeff_list)],'chebychev');
    distances(:,r) = D(1:length(target_blocks_mat(:,1)));
end

end

% build GMMs based on the chosen sample sizes for comparison
function [GMM_full,GMM_block,GMM_epoch] = channelGmmModel(input)
channels = length(input.features_full.CCs(1,:));
blocks = length(input.features_block.CCs(:,1));
epochs = length(input.features_epoch.CCs(:,1));
GMM_full = cell(1,channels);
GMM_block = cell(blocks,channels);
GMM_epoch = cell(epochs,channels);
% oh this is so bad, nested for loops
for k=1:channels
    GMM_full{k} = gmdistribution.fit(input.features_full.CCs{k}',1);
    for n=1:blocks
        GMM_block{n,k} = gmdistribution.fit(input.features_block.CCs{n,k}',1);
    end
    for m=1:blocks
        GMM_epoch{m,k} = gmdistribution.fit(input.features_epoch.CCs{m,k}',1);
    end
end
end