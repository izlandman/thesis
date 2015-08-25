% again, older function that didn't properly utitlize options available to
% me. would rebuild the models every time it was called, which was a
% terrible idea. i corrected the idea and left this as a reminder to my
% lack of forethought.

function [match_stats,match_results,match_centers,target_mahal] = defineFrequency(target_data,pool_data,v,butter_order,butter_low,butter_high,...
    analysis_frame,analysis_shift,block_time,epoch_time)

close all;

if nargin == 2
    v = 0;
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
elseif nargin == 3
    v = 1;
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

% read in the EDF data and setup filter
[target.labels,target.durations,target.data,target.sample_rate,target.duration] =...
    filePrep(target_data,fltr);

% build matrix of frequency spectrums
target.feature_set = featureFinderSlim(target.data,target.sample_rate,mf.block_time,mf.epoch_time);

% find peak frequencies in each band for each channel in each
target.feature_variables = frequencyPeakFinder(target.feature_set);

% turn everything into a matrix for the file data given
[target.variables_split,target.variables_full] = cellSmash(target.feature_variables);

%%% ----------------------------------------------------- other data source

% read in the EDF data and setup filter
% sort through pool to setup for file comparison
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_data,target_data,fltr);

for i=1:length(pool.data)
    pool.feature_set(i) = featureFinderSlim(pool.data{i},pool.sample_rate(i),mf.block_time,mf.epoch_time);
    pool.feature_variables{i} = frequencyPeakFinder(pool.feature_set(i));
    epochs = pool.feature_variables{i};
    pool_save = strcat('epochs_model_',num2str(i),'.mat');
    save(pool_save,'epochs');
    if( v == 1 )
        [pool.variables_split{i},pool.variables_full{i}] = cellSmash(pool.feature_variables{i});
    end
end

% sort out peak frequencies in the various bands to plot against each
% others, verbose only!
if( v == 1)
    channels = length(target.variables_split(1,1,:));
    plot_count = ceil(channels/2);
    
    channel_mse = zeros( max(target.variables_split(:,end,1)),channels,length(pool.data) );
    
    band_names = {'delta','theta','alpha','mu','beta','gamma'};
    for k=1:length(pool.data)
        for r=1:channels
            % math!
            target_x = max(target.variables_split(:,end,r));
            target_mean = repmat(mean(target.variables_split(:,1,r)),1,target_x);
            pool_x = max(pool.variables_split{k}(:,end,r));
            pool_mean = repmat(mean(pool.variables_split{k}(:,1,r)),1,pool_x);
            target_channel_average = mean( reshape(target.variables_split(:,1,r),...
                [],length(target.variables_split(:,1,r))/target_x), 2);
            pool_channel_average = mean( reshape(pool.variables_split{k}(:,1,r),...
                [],length(pool.variables_split{k}(:,1,r))/pool_x), 2);
            channel_mse(:,r,k) = mean( (target_channel_average - pool_channel_average).^2, 2);
            
            % plots!
            figure(k); hold on;
            subplot(2,plot_count,r);hold on; scatter(target.variables_split(:,end,r),target.variables_split(:,1,r),'b.');
            subplot(2,plot_count,r);hold on; scatter(pool.variables_split{k}(:,end,r),-pool.variables_split{k}(:,1,r),'r.');
            subplot(2,plot_count,r);hold on; plot(1:target_x,target_mean,'--m','LineWidth',2);
            subplot(2,plot_count,r);hold on; plot(1:pool_x,pool_mean,'-m','LineWidth',2);
            subplot(2,plot_count,r);hold on; plot(1:target_x,-target_channel_average,'co');
            subplot(2,plot_count,r);hold on; plot(1:pool_x,-pool_channel_average,'g*');
            title(band_names{r});
            axis([0 target_x 1.1*min(-pool.variables_split{k}(:,1,r)) 1.1*max(target.variables_split(:,1,r))]);
            
        end
        figure(k+1000);hold on;
        for i=1:channels
            subplot(2,plot_count,i);semilogy(1:target_x,channel_mse(:,i,k),'b.');
            xlim([0 target_x]);
            title(band_names{i})
        end
    end
end

% if( v == 1)
%     % reformat data, because why not
%     channels = length(target.variables_split(1,1,:));
%     pool_count = length(pool.durations);
%     pool_kmeans = zeros(sum(ceil(pool.duration./pool.sample_rate/(mf.epoch_time/2))),...
%         length(pool.feature_variables{1}(:,1,1,1)),channels);
%     strt = 1;
%     for i=1:channels
%         for r=1:pool_count
%             fnsh = strt + ceil(pool.duration(r)/pool.sample_rate(r)/(mf.epoch_time/2))-1;
%             pool_kmeans(strt:fnsh,:,i) = squeeze(pool.feature_variables{r}(:,1,i,:))';
%             strt = fnsh + 1;
%         end
%     end
% end

% not enough observations for Matlab's GMM to work
% (more observations required than variables), run kmeans first

pool_count = length(pool.durations);
channels = length(target.variables_split(1,1,:));
match_results = cell(pool_count,channels);
match_centers = cell(pool_count,channels);
target_observations = length( squeeze(target.feature_variables(1,1,1,:))');
match_stats = zeros(pool_count,channels,4);

% this is just a baseline analysis of the data to make sure it actually was
% qualities that would make it separable. if anything 'fails' later, check
% these results to see how independent the original data came out as
for i=1:pool_count
    for r=1:channels
        [match_results{i,r}, match_centers{i,r}]= kmeans( [squeeze(target.feature_variables(:,2,r,:))'; ...
            squeeze(pool.feature_variables{i}(:,2,r,:))'],2,'EmptyAction','drop','Replicates',3 );
        % calculate accuracy & error
        target_match = mode(match_results{i,r}(1:target_observations));
        target_match_true_positive = sum( match_results{i,r}(1:target_observations) == target_match );
        target_match_false_positive = sum( match_results{i,r}(target_observations+1:end) == target_match );
        target_match_true_negative = sum( match_results{i,r}(target_observations+1:end) ~= target_match );
        target_match_false_negative = sum( match_results{i,r}(1:target_observations) ~= target_match );
        % true positive
        match_stats(i,r,1) = target_match_true_positive/target_observations;
        % false positive
        match_stats(i,r,2) = target_match_false_positive/(length(match_results{i,r})-target_observations);
        % true negative
        match_stats(i,r,3) = target_match_true_negative/(length(match_results{i,r})-target_observations);
        % false negative
        match_stats(i,r,4) = target_match_false_negative/target_observations;
        
    end
end

% build GMM if possible!

pool_observations = pool.duration./pool.sample_rate / (mf.epoch_time/2) ;
pool_variable_count = length(pool.feature_variables{1}(:,1,1,1));
gm_test = (pool_observations > pool_variable_count);

if(  (min(gm_test) ~= 0) )
    pool_gmm.mu = zeros(pool_variable_count,pool_count,channels);
    pool_gmm.sigma = zeros(pool_variable_count,pool_variable_count,pool_count,channels);
    for r=1:pool_count
        for i=1:channels
            gmm_obj = gmdistribution.fit(squeeze(pool.feature_variables{r}(:,2,i,:))',1);
            % save distributions to mat files
            gmm_save = strcat('gmm_model_',num2str(r),num2str(i),'.mat');
            save (gmm_save, 'gmm_obj');
            pool_gmm.mu(:,r,i) = gmm_obj.mu;
            pool_gmm.sigma(:,:,r,i) = gmm_obj.Sigma;
        end
    end
end

% models of all pool data is built! compare to individual epochs from the
% target to find match percantages
target_mahal = zeros(target_observations,pool_count,channels);
target_average_mahal = zeros(target_observations,pool_count);

for m=1:target_observations
    for r=1:pool_count
        for i=1:channels
            gmm_obj = gmdistribution(pool_gmm.mu(:,r,i)',pool_gmm.sigma(:,:,r,i));
%             target_posterior(m,r,i,:) = posterior(gmm_obj,squeeze(target.feature_variables(:,2,i,m))');
            target_mahal(:,r,i) = mahal(gmm_obj,squeeze(target.feature_variables(:,2,i,:))');
        end
    end
end

% average the channels, not ideal. weighting should occur perhaps?

for r=1:pool_count
    target_average_mahal(:,r) = mean( squeeze(target_mahal(:,r,:)),2 );
end

% find lowest distances for each epoch when compared to each member of pool
[low_c,low_i] = min( target_average_mahal, [], 2 );

% count up matches, this works but could be better
y = zeros(max(low_i),1);
for i = 1:max(low_i)
    y(i) = sum(low_i==i);
end

clear target;
clear pool;

% generate some plots, because everyone loves plots

data_channel_averaged = mean(target_mahal,3);
[min_scale,min_scale_index] = min(data_channel_averaged);
min_scale_mat = repmat(min_scale,target_observations,1);
scaled_output = min_scale_mat ./ data_channel_averaged;
figure(42);mesh(scaled_output);
figure(86);mesh( min(min(data_channel_averaged) ) ./ data_channel_averaged );
end