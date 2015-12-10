function physioHisto(data,file_name,sample_rate,window_overlap)

[num_samples,~] = size(data);
% assumes you only have half the matrix filled out, so each entry is unique
hist_data = data;
% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['./_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[events, anno_listing, ~] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);
event_tags = unique(events);
%annotation plot
figure('numbertitle','off','name','Annotation Record Plot');
plot(anno_listing);title(file_name);xlabel('Window Index');ylabel('Event Marker');

% generate confusion plot based upon events
num_tags = length(event_tags);
tag_index = cell(num_tags,1);

event_lengths = zeros(1,length(tag_index));
% plot histogram of internal distances to help with colormap selection
figure('numbertitle','off','name','Internal Histogram');
plot_min = min(min(hist_data));
plot_max = max(max(hist_data));

for r=1:num_tags
    tag_index{r} = find(anno_listing == event_tags(r));
    event_lengths(r) = length(tag_index{r});
    hist_plot = hist_data(tag_index{r},tag_index{r});
    subplot(3,1,r);hist(hist_plot(hist_plot>0),200);
    ylabel('Window Count','fontsize',20);xlim([plot_min plot_max]);
    title_lab = ['Internal Distance, Event: T' num2str(r-1) ];
    xlabel(title_lab,'fontsize',20);
    set(gca,'fontsize',20);
    grid on;
    if( r == 1 )
        title_lab = ['Internal Distance Histogram, ' file_name];
        title(title_lab,'fontsize',20);
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
xlabel('External Distance, Event: T0 to T1','fontsize',14);
set(gca,'fontsize',20);grid on;
subplot(3,1,2);hist(hist_plot_2(hist_plot_2>0),200);
xlim([0 extern_max]);ylabel('Window Count','fontsize',14)
xlabel('External Distance, Event: T0 to T2','fontsize',14);
set(gca,'fontsize',20);grid on;
subplot(3,1,3);hist(hist_plot_3(hist_plot_3>0),200);
xlim([0 extern_max]);ylabel('Window Count','fontsize',14)
xlabel('External Distance, Event: T1 to T2','fontsize',14);
set(gca,'fontsize',20);grid on;

end