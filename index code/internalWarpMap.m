function result = internalWarpMap(data,file_name,sample_rate,window_overlap)
% take the incoming data and build up a distance matrix showing the warp
% error between samples
[num_samples,window_length] = size(data);

result = zeros(num_samples,num_samples);
norm_data = normr(data);
for r=1:num_samples
    for k=r:num_samples
        result(r,k) = dtw(norm_data(r,:)',norm_data(k,:)',window_length);
    end
end

result_full = result + result';

% remove diagonal from matrix
result_temp = result_full;
result_temp( logical( eye(size(result_temp)) ) ) = [];
result_temp = reshape(result_temp,num_samples-1,num_samples);
temp_mean = mean(result_temp);
temp_std = std(result_temp);

% -1 flags for below one stddev, +1 flags for above one stddev, 1/2 for
% within one stddev
result_flag = ones(num_samples,num_samples);
result_flag( result_full < repmat(temp_mean-temp_std,num_samples,1) ) = -1;
result_flag( result_full > repmat(temp_mean+temp_std,num_samples,1) ) = 1/3;

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['C:/_ward/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[event_tags, anno_listing] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);

% close all;
% 
% figure(20);plot(result_flag(:,20).*anno_listing)
% figure(100);plot(result_flag(:,100).*anno_listing)
% figure(200);plot(result_flag(:,200).*anno_listing)
% figure(300);plot(result_flag(:,300).*anno_listing)
% figure(400);plot(result_flag(:,400).*anno_listing)
% figure(500);plot(result_flag(:,500).*anno_listing)

save('result.mat','result_full');

end