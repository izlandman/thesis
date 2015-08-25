function result = featureSet(raw_data,coords,sample_rate,data_length)
% convert coords into indexed locations from time stamps, sort them incase
% they were entered backwards for some reason (this may be an unwise
% decision). then use these indexed values to compute the features from the
% raw data

coords_index = round( coords(:,1)*sample_rate );

feature_count = length(coords_index);

annotation_start = coords_index( mod( (1:feature_count),2 )~=0 );
annotation_end = coords_index( mod( (1:feature_count),2 )==0 );

% now build features!
result = cell(feature_count/2,1);
data_source = cell(feature_count/2,1);

% center a data window around the annotated feature, need to get enough
% data points to build out frequencies. ensure the number of points used in
% the time domain are static, otherwise their vectors cannot be compared.
% one idea is to pad up with zeros, but another could be to interoplate the
% points inbetween to pad with fake data. this needs to be a separate
% function because how this handles the data could be important once
% analysis on the variables starts
annotation_adjusted = annotationWindowCenter(annotation_start,annotation_end,sample_rate,data_length);

for i=1:feature_count/2
    data_source{i} = raw_data(annotation_adjusted.start(i):annotation_adjusted.stop(i),:);
    result{i} = featureBuild(data_source{i},sample_rate,...
        annotation_adjusted.start(i),annotation_adjusted.stop(i),coords(i*2,3));
end

end