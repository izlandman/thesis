
shape = 'square';
base_window = 50;
overlap = 25;
sample_rate = 200;
file_list = matchFileName('__MR_0.txt');
data_columns = [ 2 3 ];

total_samples = length(file_list{1}(:,1));
iterations = ( total_samples - base_window ) / base_window;
signals = length(data_columns);
test_run = cell(iterations,1);

close all;

for i=1:iterations
    test_run{i} = featureMapping(file_list{1},[1 3],sample_rate,overlap,...
        shape,i*base_window+base_window);
    figure(i);
    for r=1:signals
        subplot(signals,1,r);plot(test_run{i}(:,3),test_run(:,r));
    end
end

test_run_diff = cellfun(@diff,test_run,'uniformoutput',0);
% use this to get rid of lonely minimums in the data, only count 'feature's
% for sequential minimums
test_run_mean = cell2mat(cellfun(@mean,test_run,'uniformoutput',0));
test_run_binary = cell(iterations,1);

for i=1:iterations
    index_1 = find( test_run_mean(i,1) > test_run{i}(:,1) );
    test_run_binary{i} = abs(test_run{i}(:,1));
    test_run_binary{i}(index_1,1) = 1 ;
    index_2 = find( test_run_binary{i} ~= 1 );
    test_run_binary{i}(index_2,1) = 0;
end

% fitler to group matches
window_size = 5;
b = (1/window_size)*ones(window_size,1);
a =  1 ;

for g=1:iterations
    
    test_run_filtered{g} = filter(b,a, test_run_binary{g}(:,1));
    
end