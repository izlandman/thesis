function result = internalWarpMap(data,file_name,sample_rate,window_overlap)
% take the incoming data and build up a distance matrix showing the warp
% error between samples
[num_samples,window_length] = size(data);

result = zeros(num_samples,num_samples);
for r=1:num_samples
    for k=1:num_samples
        result(r,k) = dtw(data(r,:),data(k,:),10);
    end
end

% remove diagonal from matrix
result_temp = result;
result_temp( logical( eye(size(result_temp)) ) ) = [];
result_temp = reshape(result_temp,num_samples-1,num_samples);
temp_mean = mean(result_temp);
temp_std = std(result_temp);

% -1 flags for below one stddev, +1 flags for above one stddev, 1/2 for
% within one stddev
result_flag = ones(num_samples,num_samples);
result_flag( result < repmat(temp_mean-temp_std,num_samples,1) ) = -1;
result_flag = reshape(result_flag,num_samples,num_samples);
result_flag( result > repmat(temp_mean+temp_std,num_samples,1) ) = 1/3;
result_flag = reshape(result_flag,num_samples,num_samples);

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['C:/_ward/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[event_tags, anno_listing] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);


end