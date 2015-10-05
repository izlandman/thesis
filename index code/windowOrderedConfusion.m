function windowOrderedConfusion(data,file_name,sample_rate,window_overlap)
close all;
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

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['./_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[events, anno_listing, anno_index] = ...
    annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);
event_tags = unique(events);
% generate confusion plot based upon events
num_tags = length(event_tags);
tag_index = cell(num_tags,1);
% generate an index of events so they can be grouped for confusion matrix
new_index = [];

for r=1:num_tags
    tag_index{r} = find(anno_listing == event_tags(r));
    event_lengths(r) = length(tag_index{r});
    new_index = [new_index tag_index{r}'];
end

% index each task
tasks = length(anno_index);
% event threshold lines
g_coord = zeros(1,tasks);
g_coord(1) = 1;
for i=1:length(anno_index)
    g_coord(i+1) = g_coord(i) + anno_index(i);
end
x_coord = g_coord;
ordered_windows = [];

for r=1:min(anno_index)
    index_1 = x_coord(1:end-1)+r-1;
    ordered_windows = [ordered_windows new_index(index_1)];
end
result_full(result_full == 0)= NaN;
short_side = length(ordered_windows);
figure('numbertitle','off','name','Window Ordered Tasks, Skimmed');
mesh(result_full(ordered_windows,ordered_windows));view(0,90);
axis([0 short_side 0 short_side]);axis square;
% get my color map
R = load('myColorMap1');
colormap(R.myColorMapBluePink);
title(['Subject: ' file_name ' Window Ordered Confusion Matrix'],'fontweight','bold','fontsize',16);
ylabel('Window Index','fontsize',14);xlabel('Window Index','fontsize',14);colorbar;
view(0,90);

test_final = zeros(tasks,max(anno_index));
x_coord(1) = 1;
for t=1:max(anno_index)
    index_test = x_coord(1:end-1)+t-1;
    if( t > 1 )
        % don't write longer than the true window size
        valid_check = (index_test'>test_final(:,t-1));
        % ensure you don't index too far
        excess_check = (index_test > num_samples);
        % combine verification, if anything is modified don't store it
        full_check = valid_check' + excess_check;
        index_test(excess_check) = 1;
    end
    test_final(:,t) = new_index(index_test);
end

end