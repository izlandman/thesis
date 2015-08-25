function results = featureTestingSingle(test_name,iterations,varargin)

close all;

test_annotations_file = matchFileName( [test_name '_ann'] );
test_annotations = csvread(test_annotations_file{1},3,0);
feature_count = max(test_annotations(:,1));

results = zeros(5,feature_count,iterations);

if( nargin > 2 )
    
    for i=1:iterations
        [a,b,c,d,e] = featureTesting(test_name,varargin{1});
        results(:,:,i) = [a b c d e]';
    end
    
else
    for i=1:iterations
         [a,b,c,d,e] = featureTesting(test_name);
         results(:,:,i) = [a b c d e]';
    end
end

if( nargin > 3 )
    
    figure_titles = {'True Positives', 'False Negatives', 'Sensitivity', ...
        'Feature Overlap' 'Data Reduction'};
    
    for k=1:numel(figure_titles)
        plotStat2(squeeze(results(k,:,:))',figure_titles{k},feature_count);
    end
    
end

end

function plotStat2(data,fig_title,num_feat)

feat_titles = {'Feature 1','Feature 2','Feature 3','Feature 4'};

figure('name',fig_title,'numbertitle','off');
plot((1:length(data)),data,'linewidth',2);
ylim([ -0.1 max(max(data))+0.1 ]);
xlabel('Iterations');
ylabel(fig_title);
legend(feat_titles(1:num_feat));

end