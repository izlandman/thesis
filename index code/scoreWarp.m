function [result_flag,anno_listing] = scoreWarp(data,file_name,sample_rate,window_overlap)

[num_samples,~] = size(data);
% if the matrix isn't full, complete the columns
x_row = round(num_samples/2);
x_col = x_row + 1;
hist_data = data;
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
%annotation plot
figure('numbertitle','off','name','Annotation Record Plot');
plot(anno_listing);

% generate confusion plot based upon events
num_tags = length(event_tags);
tag_index = cell(num_tags,1);
% generate an index of events so they can be grouped for confusion matrix
new_index = [];

% plot histogram of internal distances to help with colormap selection
figure('numbertitle','off','name','Internal Histogram');
plot_min = min(min(hist_data));
plot_max = max(max(hist_data));
for r=1:num_tags
    tag_index{r} = find(anno_listing == event_tags(r));
    new_index = [new_index tag_index{r}'];
    hist_plot = hist_data(tag_index{r},tag_index{r});
    subplot(3,1,r);hist(hist_plot(hist_plot>0),50);
    xlabel('distance');ylabel('window count');xlim([plot_min plot_max]);
    title_lab = ['internal distance of event ' num2str(r) ];
    title(title_lab);
end

confusion_data = result_full(new_index,new_index);
% remove the zeros, which should only be for cases of identity
confusion_data(confusion_data==0) = NaN;
load calibrated_color.mat;
figure('numbertitle','off','name','DTW Confusion Matrix');
mesh(confusion_data);colormap(calibrated_color_map);
xlim([0 num_samples]);ylim([0 num_samples]);
ylabel('window index');xlabel('window index');colorbar;
view(0,90);

end