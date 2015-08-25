function result = buildBlandData(feature_coords,sample_rate,yY,...
    window_start,window_end)
bland_feature_set = {};
% data unassigned is assumed to not be of interest, use it to train
% LDA. build vector of 'bland' data for training algorithm.
bland_data = blandTrainingData(feature_coords*sample_rate,yY);
% turn the bland data into features, be sure each feature is made in
% the same size as a real feature
bland_length = length(bland_data(:,1));
if( bland_length >= sample_rate )
    bland_feat_count = floor( (bland_length-sample_rate)/ round(sample_rate/4) );
    start = 1;
    finish = start + sample_rate - 1;
    while( bland_feat_count >= 1 )
        bland_data_trim = bland_data(start:finish,:);
        bland_feature = featureBuild(bland_data_trim,sample_rate,...
            start,finish,42);
        bland_feature_set = distillFeature(bland_feature,bland_feature_set);
        start = start + round(sample_rate/4);
        finish = start + sample_rate - 1;
        bland_feat_count = bland_feat_count - 1;
    end
end

result = bland_feature_set';

end