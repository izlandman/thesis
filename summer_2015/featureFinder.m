function result = featureFinder(raw_data,window_start,window_end,...
    sample_rate,data_length,true_features,LDA_models)
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

if( window_end >= data_length )
    window_samples =floor( (data_length - window_start + 1 + sample_rate) / ...
        (sample_rate*sample_scaling) + 1 );
else
    window_samples = floor( (window_end - window_start + 1 + sample_rate) /...
        (sample_rate*sample_scaling) + 1 );    
end

cho_feat = 1;
feature_samples = length(true_features);
d_s_mat = zeros(feature_samples,window_samples,2);
feature_comparison = zeros(window_samples,feature_samples,length(cho_feat));

for i=1:window_samples
    
    left_pointer = window_start + (i - 1)*floor(sample_rate*sample_scaling);
    
    [operational_start, operational_finish] = operationalWindow(...
        left_pointer,sample_rate,data_length);
    
    found_feature = featureBuild(raw_data(operational_start:...
        operational_finish,:),sample_rate,operational_start,...
        operational_finish,11);
    
    % warp features!
    % contiunous dynamic time warping data
    for r=1:feature_samples
        [d_s_mat(r,i,1),~,d_s_mat(r,i,2),~,true_features{r}.features{1},...
            found_feature.features{1}] = cdtw2( true_features{r}.source(:,3),...
            found_feature.source(:,3),0 );
        
        feature_comparison(i,r,:,:) = featureCompare(found_feature,...
            true_features{r},cho_feat);
    end
end

highlight_feature = raw_data(window_start:window_end,:);

% At this point something should happen to the feature_compare vector. It
% contains raw distances between all of the features and signals, but it
% probably needs to be weighted in some way. Perhaps weight the features
% themselves and let them vote in each time slot. Then smooth/average these
% votes to find strong clumps that indicate the presence of a feature (keep
% in mind the sample rate of the data) over so many contiunous samples.
% These votes would need to be based on a model of the distribution (
% should the distributions be tracked on an annotation basis or based upon
% the sensor it came from so many options ).


% find best matches given the features built from the window scan. matches
% are given as point in time, so rebuild windows from best_matches and
% highlight next window to help user. the LDA results attempt to classify
% the data via power bands of specific frequencies. the index of the
% matches [ 1 == annotation, 3 == bland ] can be used to highlight areas in
% of the next window for analysis or removal.


% length(true_features)
% if( length(true_features) > 1 )
%     lda_results = ldaDiscrimData(LDA_models,features_found);
% else
%     lda_results = zeros(2,window_samples-1);
% end

% for feeding in LDA results
% good_data = windowFiller(lda_results,sample_rate,highlight_feature,window_end);

% for feeding in kmeans results, channel selection allows for variation in
% which data channels are used to build the feature match results

good_data = windowFillerKmeans(feature_comparison,sample_rate,...
    highlight_feature);
highlight_feature = highlight_feature .* good_data;
result = highlight_feature;

end

function result = windowFillerKmeans(feature_comparison,sample_rate,...
    highlight_feature)

window_end = length(highlight_feature);
result = zeros(size(highlight_feature));
[indicts,feats] = size(feature_comparison);

for i=1:feats;
    
    [indx,cc] = kmeans(1./feature_comparison(:,i),2);
    
    if( sum( indx==1 ) < sum( indx==2 ) )
        index = (find(indx == 1)-1)*floor(sample_rate/4);
    else
        index = (find(indx == 2)-1)*floor(sample_rate/4);
    end
    
    fill_start = index - floor(sample_rate/2);
    fill_finish = index + floor(sample_rate/2) - 1;
    
    fill_start(fill_start<1) = 1;
    fill_finish(fill_finish>window_end) = window_end;
    
    spots = cell2mat(arrayfun(@colon, fill_start',fill_finish','UniformOutput',0));
    
    result(spots,:) = 1;
end

end

function result = windowFiller(lda_results,sample_rate,highlight_feature,window_end)
result = zeros(size(highlight_feature));
index = (find(lda_results == 1)-1)*floor(sample_rate/4);

fill_start = index - floor(sample_rate/2);
fill_finish = index + floor(sample_rate/2) - 1;

fill_start(fill_start<1) = 1;
fill_finish(fill_finish>window_end) = window_end;

spots = cell2mat(arrayfun(@colon, fill_start',fill_finish','UniformOutput',0));

result(spots) = 1;

end

% adjusts window to allow for overlap when searching for matching signal
function [operational_start,operational_finish] = operationalWindow(...
    window_start,sample_rate,data_length)
operational_start = window_start - floor(sample_rate/2);
if( operational_start < 1 )
    operational_start = 1;
end
operational_finish = operational_start + sample_rate - 1;
if( operational_finish > data_length )
    operational_finish = data_length;
end
end