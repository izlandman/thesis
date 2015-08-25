% Build GMM and save them into an auto generated folder. Also track the
% valid creation of GMMs in the event that a subject has too few samples to
% generate a proper model via valid.mat

% INPUTS: Identical inputs for _buildEpochMats_ and _buildGmmMats_

% OUTPUTS: generates a gmm file with the object gmm_obj and valid model
% file gm_test

function buildGmmMats(pool_data,butter_order,butter_low,butter_high,...
    analysis_frame,analysis_shift,block_time,epoch_time)

close all;

if nargin == 1
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
    mf.block_time = 10;
    mf.epoch_time = 1.5;
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

target_data = '';

new_directory = strcat(datestr(date),'_',pool_data,'_gmm');

% verify the directory doesn't exist already
if( exist(new_directory,'dir') == 7 )
    prompt = 'Directoy already exists. Delete and replace?[y/n]';
    response = input(prompt,'s');
    if( response == 'y' || response == 'Y' )
        rmdir(new_directory,'s');
        mkdir(new_directory);
    else
        error('Cannot make new directory. User aborted.');
    end
else
    mkdir(new_directory);
end

% import data
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_data,target_data,fltr);

% for i=1:length(pool.data)
%     pool.feature_set(i) = featureFinderSlim(pool.data{i},pool.sample_rate(i),mf.block_time,mf.epoch_time);
%     pool.feature_variables{i} = frequencyPeakFinder(pool.feature_set(i));
% end

% build and save models
pool_count = length(pool.data);
% channels = length(feature_variables(1,1,:,1));
pool_observations = pool.duration./pool.sample_rate / (mf.epoch_time/2) ;
% pool_variable_count = length(pool.feature_variables{1}(:,1,1,1));
% gm_test = (pool_observations > pool_variable_count);

% valid_models = strcat(new_directory,'\','valid_gm','.mat');
% save( valid_models, 'gm_test');
pool_variable_count = zeros(1,length(pool.data));
% pool_gmm.mu = zeros(pool_variable_count,pool_count,channels);
% pool_gmm.sigma = zeros(pool_variable_count,pool_variable_count,pool_count,channels);
for r=1:pool_count
    % break the data down
    feature_set = featureFinderSlim(pool.data{r},pool.sample_rate(r),mf.block_time,mf.epoch_time);
    feature_variables = frequencyPeakFinder(feature_set);
    channels = length(feature_variables(1,1,:,1));
    pool_variable_count(r) = length(feature_variables(:,1,1,1));
    % ensure that there are more rows than columns, more observations
    % than variables otherwise gmdist won't fit the data. this will
    % cause some holes in the models, but oh well?
    if( (pool_observations(r) >= pool_variable_count(r)) ~= 0 )
        gmm_obj = cell(6,1);
        for i=1:channels
            gmm_obj{i} = gmdistribution.fit(squeeze(feature_variables(:,2,i,:))',1);
        end
            % save distributions to mat files
            gmm_save = strcat(new_directory,'\','gmm_model_',num2str(r),'.mat');
            save (gmm_save, 'gmm_obj');

        disp( ['Saving ',num2str(r),' of ', num2str(pool_count) ] );
    end
end

gm_test = (pool_observations > pool_variable_count);
valid_models = strcat(new_directory,'\','valid_gm','.mat');
save( valid_models, 'gm_test');

end