function featureTestingPlot(test_name,varargin)

close all;

if( nargin > 1 )
    dB_levels = varargin{1};
else
    dB_levels = [-3 -1 0 1 3 10 20];
end

num_dB = length(dB_levels);
M = csvread( [test_name '_ann.dat'],4,0 );
feature_count = max( M(:,1)  );

true_positives = zeros(num_dB,feature_count);
false_negatives = true_positives;
false_positives = true_positives;
sensitivity = false_negatives;
FDR = false_negatives;
overlap = sensitivity;
reduction = overlap;

for i=1:num_dB
    [true_positives(i,:),false_positives(i,:), false_negatives(i,:), ...
        sensitivity(i,:), FDR(i,:), overlap(i,:), reduction(i,:)] = ...
        featureTesting(test_name,dB_levels(i));
end

figure_titles = {'True Positives' 'False Positives' 'False Negatives' ...
    'Sensitivity' 'False Discovery Rate' 'Feature Overlap' 'Data Reduction'};

full_data = cat(3,true_positives,false_positives,false_negatives,sensitivity,FDR,overlap,reduction);

% make new directory in present folder and save plots
dt = datestr(now,'yyyy_mm_dd_HH_MM_SS');
new_folder = [test_name '_plot_' dt];
mkdir(new_folder);

for k=1:numel(figure_titles)
    plotStat(squeeze(full_data(:,:,k)),dB_levels,figure_titles{k},feature_count);    
    saveas(gcf,['.\' new_folder '\' figure_titles{k} '.png']);
end
fid = fopen(['.\' new_folder '\' 'values.dat'],'w');
fprintf(fid,'%s\t %s\t %s\t %s\t %s\t %s\t %s\r\n',figure_titles{:});
fclose(fid);
dlmwrite(['.\' new_folder '\' 'values.dat'],squeeze(full_data),'delimiter','\t','-append');
dlmwrite(['.\' new_folder '\' 'values.dat'],squeeze(dB_levels),'delimiter','\t','-append');

end