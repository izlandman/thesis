function result = featureFinderAuto(raw_data,true_features,sample_rate)
% given the updated window and assumed updated features, comb the new chunk
% of data for features that match those already in the template database.
% do this cover all possible windows of size sample_rate that touch the
% passed in window defined by window_start and window_end. meaning that the
% first operational scan starts at window_start - sample_rate and the final
% one terminates when the end of the operational window reaches
% window_end+sample_rate

% given window size is 'standard' of 30 seconds, iterating through every
% instance will be time intensive so maybe only use windows of 10 seconds

sample_scaling = 0.25;
data_length = length(raw_data);
cho_feat = 1;
feature_samples = length(true_features);
result = zeros(data_length,length(true_features));
% these need to know how many samples will be made
d_s_mat = zeros(feature_samples,2);
center_pointer(1:feature_samples,1) = 1;

for r=1:feature_samples
    window_size = true_features{r}.duration;
    while center_pointer(r) < data_length
        
        % window_size should be equal to the length of the found feature being
        % compared to the raw data, eventually window_size should adjust given
        % that features can be of the same type but potentially vary in size
        [operational_data,operational_start,operational_finish] = ...
            operationalWindow(center_pointer(r,1),window_size,data_length,raw_data);
        
        
        % build feature from new window of data
        found_feature = featureBuild2(operational_data,window_size,...
            operational_start,operational_finish,11);
        
        % warp features!
        % contiunous dynamic time warping data
        
        % normalize because all the papers say DTW needs normalized vectors
        % true_feat = true_features{r}.source(:,3) / norm( true_features{r}.source(:,3) );
        % true_feat = true_feat - mean(true_feat);
        % found_feat = found_feature.source(:,3) / norm( found_feature.source(:,3) );
        % found_feat = found_feat - mean(found_feat);
        % or don't normalize, I mean let's do some science eh?
        true_feat = true_features{r}.source(:,3);
        found_feat = found_feature.source(:,3);
        [d_s_mat(r,1),~,d_s_mat(r,2),~,true_features{r}.features{1},...
            found_feature.features{1}] = cdtw2( true_feat,found_feat,0 );
        
        % compute distance between found feature and known feature
        feature_comparison = featureCompare(found_feature,...
            true_features{r},cho_feat);
        % given known range, write value of feature_comparison in if zeros
        % are present (assumes there is never a perfect match) then check
        % overlapping data for smallest value
        valid_updates = result(operational_start:operational_finish,r);
        valid_updates(valid_updates==0) = feature_comparison;
        valid_updates(valid_updates>feature_comparison) = feature_comparison;
        result(operational_start:operational_finish,r) = valid_updates;
        center_pointer(r,1) = center_pointer(r,1) + round( window_size *sample_scaling );
    end
    
    % group via kmeans
    features = log10(1./result(:,r));
    [indx,C] = kmeans( features, 2);
    % assume that the larger mean is a positive feature match
    [~,true_index] = max(C);
    result(indx==true_index,r) = 3;
    result(indx~=true_index,r) = 0;
end

end


% adjusts window to allow for overlap when searching for matching signal
function [operational_data,operational_start,operational_finish] = ...
    operationalWindow(window_center,window_size,data_length,raw_data)

[~,etc] = size(raw_data);
operational_data = zeros(window_size,etc);

operational_start = window_center - floor(window_size/2);
if( operational_start < 1 )
    operational_start = 1;
end
operational_finish = window_center + floor(window_size/2) - 1;
if( operational_finish > data_length )
    operational_finish = data_length;
end

window_length = operational_finish-operational_start;
operational_data(end-window_length:end,:) = ...
    raw_data(operational_start:operational_finish,:);
end