function [good_distance,bad_distance]=annotationFeature(coords_g,coords_b,sample_rate)
% convert coords into indexed locations from time stamps, sort them incase
% they were entered backwards for some reason (this may be an unwise
% decision)

coords_g_index = sort( round( coords_g(:,1)*sample_rate ), 1, 'ascend' );
coords_b_index = sort( round( coords_b(:,1)*sample_rate ), 1, 'ascend' );

good_feature_count = length(coords_g_index);
bad_feature_count = length(coords_b_index);

annotation_good_start = coords_g_index( mod( (1:good_feature_count),2 )~=0 );
annotation_good_end = coords_g_index( mod( (1:good_feature_count),2 )==0 );

annotation_bad_start = coords_b_index( mod( (1:bad_feature_count),2 )~=0 );
annotation_bad_end = coords_b_index( mod( (1:bad_feature_count),2 )==0 );

% now build features!
good_features = cell(good_feature_count/2,3);
bad_features = cell(bad_feature_count/2,3);

for i=1:good_feature_count/2
    good_features(i,:) = featureBuild(raw_data(annotation_good_start(i):...
        annotation_good_end(i)),sample_rate);
end
for i=1:bad_feature_count/2
    bad_features(i,:) = featureBuild(raw_data(annotation_bad_start(i):...
        annotation_bad_end(i)),sample_rate);
end

good_distance = zeros(3,good_feature_count/2,good_feature_count/2);
bad_distance = zeros(3,bad_feature_count/2,bad_feature_count/2);

for i=1:good_feature_count/2
    for r=1:good_feature_count/2
        good_distance(:,i,r) = featureCompare( good_features{i,1},good_features{i,2},...
            good_features{i,3},good_features{r,1},good_features{r,2},good_features{r,3});
    end
end

for i=1:bad_feature_count/2
    for r=1:bad_feature_count/2
        bad_distance(:,i,r) = featureCompare( bad_features{i,1},bad_features{i,2},...
            bad_features{i,3},bad_features{r,1},bad_features{r,2},bad_features{r,3});
    end
end
end