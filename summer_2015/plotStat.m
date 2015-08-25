function plotStat(data,labels,fig_title,feature_count)

feat_titles = {'Feature 1','Feature 2','Feature 3','Feature 4'};

y_max = max(data);
if( numel(y_max) ~= 1 )
    y_max = max(y_max);
end

figure('name',fig_title,'numbertitle','off');
plot(data,'linewidth',2);
ylim([ -0.1 y_max+0.1 ]);
set(gca,'XTick', 1:length(labels) );
set(gca,'XTickLabel',labels);
xlabel('SNR (dB)');
ylabel(fig_title);
legend(feat_titles(1:feature_count),'Location','SouthOutside','Orientation','horizontal');

end