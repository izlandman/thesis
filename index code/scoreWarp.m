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
anno_name = ['./_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[events, anno_listing, anno_index] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);
event_tags = unique(events);
%annotation plot
figure('numbertitle','off','name','Annotation Record Plot');
plot(anno_listing);title(file_name);xlabel('Window Index');ylabel('Event Marker');

% generate confusion plot based upon events
num_tags = length(event_tags);
tag_index = cell(num_tags,1);
% generate an index of events so they can be grouped for confusion matrix
new_index = [];
event_lengths = zeros(1,length(tag_index));
% plot histogram of internal distances to help with colormap selection
figure('numbertitle','off','name','Internal Histogram');
plot_min = min(min(hist_data));
plot_max = max(max(hist_data));

for r=1:num_tags
    tag_index{r} = find(anno_listing == event_tags(r));
    event_lengths(r) = length(tag_index{r});
    new_index = [new_index tag_index{r}'];
    hist_plot = hist_data(tag_index{r},tag_index{r});
    subplot(3,1,r);hist(hist_plot(hist_plot>0),200);
    ylabel('Window Count','fontsize',14);xlim([plot_min plot_max]);
    title_lab = ['Internal Distance, Event: ' num2str(r) ];
    xlabel(title_lab,'fontsize',14);
    set(gca,'fontsize',14);
    if( r == 1 )
        title_lab = ['Internal Distance Histogram, ' file_name];
        title(title_lab,'fontsize',14);
    end
end

figure('numbertitle','off','name','External Histogram');
hist_plot_1 = hist_data(tag_index{1},tag_index{2});
hist_plot_2 = hist_data(tag_index{1},tag_index{3});
hist_plot_3 = hist_data(tag_index{2},tag_index{3});

extern_max = max( [max(hist_plot_1) max(hist_plot_2) max(hist_plot_3)] );

subplot(3,1,1);hist(hist_plot_1(hist_plot_1>0),200);
title_t = [ 'External Distance Histogram, ' file_name ];
title(title_t, 'fontsize',14);
xlim([0 extern_max]);ylabel('Window Count','fontsize',14)
xlabel('External Distance, Event: 0 to 1','fontsize',14);
set(gca,'fontsize',14);
subplot(3,1,2);hist(hist_plot_2(hist_plot_2>0),200);
xlim([0 extern_max]);ylabel('Window Count','fontsize',14)
xlabel('External Distance, Event: 0 to 2','fontsize',14);
set(gca,'fontsize',14);
subplot(3,1,3);hist(hist_plot_3(hist_plot_3>0),200);
xlim([0 extern_max]);ylabel('Window Count','fontsize',14)
xlabel('External Distance, Event: 1 to 2','fontsize',14);
set(gca,'fontsize',14);

confusion_data = result_full(new_index,new_index);
% remove the zeros, which should only be for cases of identity
conf_data_saved = confusion_data;
confusion_data_2 = normc(conf_data_saved);
confusion_data(confusion_data==0) = NaN;
max_conf = max(max(confusion_data));
% confusion_data(confusion_data<max_conf*.70) = NaN;
confusion_data_2(confusion_data_2==0) = NaN;
figure('numbertitle','off','name','DTW Confusion Matrix');
% normalize distance?
% anorm = (confusion_data - min(min(confusion_data)))/(max(max(confusion_data))-min(min(confusion_data)));
plot_this = (confusion_data);
mesh(plot_this,'LineWidth',3);
% get my color map
R = load('myColorMap1');
colormap(R.myColorMapBluePink);
title(['Subject: ' file_name ' Confusion Matrix'],'fontweight','bold','fontsize',16);
xlim([1 num_samples]);ylim([1 num_samples]);
ylabel('Window Index','fontsize',14);xlabel('Window Index','fontsize',14);colorbar;
view(0,90);

peak_val = max(max(plot_this));

% T0 threshold
T0_thresh = event_lengths(1) + 1;
line([1 num_samples],[T0_thresh T0_thresh],[peak_val peak_val],'linewidth',2,'color','k');
line([T0_thresh T0_thresh],[1 num_samples],[peak_val peak_val],'linewidth',2,'color','k');
% T1 threshold
T1_thresh = T0_thresh + event_lengths(2);
line([1 num_samples],[T1_thresh T1_thresh],[peak_val peak_val],'linewidth',2,'color','k');
line([T1_thresh T1_thresh],[1 num_samples],[peak_val peak_val],'linewidth',2,'color','k');

% event threshold lines
g_coord = zeros(1,length(anno_index));
g_coord(1) = 0;
for i=1:length(anno_index)
    g_coord(i+1) = g_coord(i) + anno_index(i);
end
x_coord = g_coord + 1;
x_coord(1) = 1;
g_coord = g_coord + 2;
g_coord(1) = 1;
for i=1:length(g_coord)
    line([x_coord(i) x_coord(i)],[1 num_samples],[peak_val peak_val],'linewidth',1,'color','k');
end

axisLabels = num2cell( new_index(g_coord(1:end-1)) );
set(gca,'xTick',linspace(1,num_samples-anno_index(end),length(anno_index)),'XTickLabel',axisLabels);
set(gca,'yTick',linspace(1,num_samples-anno_index(end),length(anno_index)),'YTickLabel',axisLabels);
set(gca,'FontSize',14);

% edit to make separate plot for artifacts or areas of interest
figure('numbertitle','off','name','DTW Confusion Matrix Artifact');
% normalize distance?
% anorm = (confusion_data - min(min(confusion_data)))/(max(max(confusion_data))-min(min(confusion_data)));
plot_this = (confusion_data);
mesh(plot_this,'LineWidth',5);
% get my color map
R = load('myColorMap1');
colormap(R.myColorMapBluePink);
title(['Subject: ' file_name ' Confusion Matrix'],'fontweight','bold','fontsize',16);
xlim([1 num_samples]);ylim([1 num_samples]);
ylabel('Window Index','fontsize',14);xlabel('Window Index','fontsize',14);colorbar;
view(0,90);

peak_val = max(max(plot_this));

% T0 threshold
T0_thresh = event_lengths(1) + 1;
line([1 num_samples],[T0_thresh T0_thresh],[peak_val peak_val],'linewidth',2,'color','k');
line([T0_thresh T0_thresh],[1 num_samples],[peak_val peak_val],'linewidth',2,'color','k');
% T1 threshold
T1_thresh = T0_thresh + event_lengths(2);
line([1 num_samples],[T1_thresh T1_thresh],[peak_val peak_val],'linewidth',2,'color','k');
line([T1_thresh T1_thresh],[1 num_samples],[peak_val peak_val],'linewidth',2,'color','k');

% event threshold lines
g_coord = zeros(1,length(anno_index));
g_coord(1) = 0;
for i=1:length(anno_index)
    g_coord(i+1) = g_coord(i) + anno_index(i);
end
x_coord = g_coord + 1;
x_coord(1) = 1;
g_coord = g_coord + 2;
g_coord(1) = 1;
for i=1:length(g_coord)
    line([x_coord(i) x_coord(i)],[1 num_samples],[peak_val peak_val],'linewidth',1,'color','k');
end

axisLabels = num2cell( new_index(g_coord(1:end-1)) );
set(gca,'xTick',linspace(1,num_samples-anno_index(end),length(anno_index)),'XTickLabel',axisLabels);
set(gca,'yTick',linspace(1,num_samples-anno_index(end),length(anno_index)),'YTickLabel',axisLabels);
set(gca,'FontSize',14);
ylim([299 335]);

end