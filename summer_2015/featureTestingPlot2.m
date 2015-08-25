function featureTestingPlot2(test_name,varargin)

close all;

dB_levels = [-3 -1 0 1 3 10 20];

if( nargin > 2 )
    iterations = varargin{1};
    dB_levels = varargin{2};
elseif( nargin > 1 )
    iterations = varargin{1};
else
    % null case
end

num_dB = length(dB_levels);
M = csvread( [test_name '_ann.dat'],4,0 );
feature_count = max( M(:,1)  );

results = zeros(5,feature_count,num_dB);


for i=1:num_dB
    result = featureTestingSingle(test_name,iterations,dB_levels(i),1);
    results(:,:,i) = mean(result,3);
end

figure_titles = {'True Positives', 'False Negatives', 'Sensitivity', ...
    'Feature Overlap' 'Data Reduction'};

% make new directory in present folder and save plots
dt = datestr(now,'yyyy_mm_dd_HH_MM_SS');
new_folder = [test_name '_plot_' dt];
mkdir(new_folder);

for k=1:numel(figure_titles)
    plotStat(squeeze(results(k,:,:))',dB_levels,figure_titles{k},feature_count);    
    saveas(gcf,['.\' new_folder '\' figure_titles{k} '.png']);
end


end