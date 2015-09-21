function [result_flag,anno_listing] = scoreWarp(data,file_name,sample_rate,window_overlap)

[num_samples,~] = size(data);
% if the matrix isn't full, complete the columns
x_row = round(num_samples/2);
x_col = x_row + 1;
if( data(x_row,x_col) ~= data(x_col,x_row))
    data = data + data';
end

result_full = data;
% remove diagonal from matrix
data( logical( eye(size(data)) ) ) = [];
data = reshape(data,num_samples-1,num_samples);
temp_mean = mean(data);
temp_std = std(data);

% -1 flags for below one stddev, +1 flags for above one stddev, 1/2 for
% within one stddev
result_flag = ones(num_samples,num_samples);
result_flag( result_full < repmat(temp_mean-2*temp_std,num_samples,1) ) = -1;
result_flag( result_full > repmat(temp_mean+2*temp_std,num_samples,1) ) = 1/3;

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['C:/_ward/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[event_tags, anno_listing] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);

end