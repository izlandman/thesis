function myHeatMap(window_index,raw_data,distance_data)
close all;
full_distance = distance_data + distance_data';
plot_distance_data = full_distance(:,window_index);
nan_plot_dist = plot_distance_data;
nan_plot_dist(nan_plot_dist==0) = [];
mean_plot_dist = nanmean(nan_plot_dist);
std_plot_dist = nanstd(nan_plot_dist);
upper_thresh = mean_plot_dist + 2*std_plot_dist;
lower_thresh = mean_plot_dist - 2*std_plot_dist;

plot_raw_data = raw_data(window_index,:);
figure('numbertitle','off','name','Something like a heat map');
subplot(411);plot(plot_raw_data,'k');
subplot(412);plot(plot_distance_data > upper_thresh,'k');
xlim([1 length(plot_distance_data)]);ylim([-1 2]);
subplot(413);plot(plot_distance_data,'k');
line([1 length(plot_distance_data)],[mean_plot_dist mean_plot_dist],'color','r');
line([1 length(plot_distance_data)],[lower_thresh lower_thresh],'color','b');
line([1 length(plot_distance_data)],[upper_thresh upper_thresh],'color','b');
xlim([1 length(plot_distance_data)]);
subplot(414);plot(plot_distance_data < lower_thresh,'k');
xlim([1 length(plot_distance_data)]);ylim([-1 2]);
end