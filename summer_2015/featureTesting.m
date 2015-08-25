% this file will allow for statistics to be collected from test data
% generated using accelerometer data from intern movement habits.
% test_vector can be built by calling generateAccelProfile that stitches
% together given subsets of data. To ascertain the details of the dataset a
% file of annotations, test_annotations, must be generated by hand to
% indicate the sample rate and location/type of event seen in the sample
% data. this will allow for statistical analysis of the test_vector.

function [true_positive,false_positive,false_negative,sensitivity,FDR,...
    overlap,reduction] = featureTesting(test_name,varargin)

close all;

% build feature csv files if they aren't made already
% gather test vector data
test_data_file = matchFileName( [test_name '_raw'] );
test_data = csvread(test_data_file{1});

if( nargin > 2 )
    
    noise_coeff = varargin{1};
    test_features_files = varargin{2};
    feature_count = varargin{3};
    transition_spacing = varargin{4};
    
    generateFeatureVector(test_features_files,feature_count,...
        transition_spacing,test_name);
    
    % add white gaussian noise, noise_coeff is SNR (dB)
    test_data = awgn(test_data,noise_coeff,'measured');
    
elseif( nargin == 2 )
    
    % test name and noise level entered
    noise_coeff = varargin{1};
    
    % add white gaussian noise, noise_coeff is SNR (dB)
    test_data = awgn(test_data,noise_coeff,'measured');
    
else
    % no noise, life is goood
end

% extract data from associated annotaion file
test_annotations_file = matchFileName( [test_name '_ann'] );
test_annotations = csvread(test_annotations_file{1},3,0);
feature_count = max(test_annotations(:,1));

fid = fopen(test_annotations_file{1});
data = fread(fid,'*char');
fclose(fid);
entries = regexp(data','\t','split');
for i=1:feature_count
    test_file_names{i} = entries{i};
    features_in_file(i) = str2num(entries{i+feature_count});
end

sample_rate = str2num(entries{feature_count*2+1});

valid_regions = zeros(length(test_data),feature_count);
false_pos_clear = valid_regions;
anno_starts = test_annotations(:,1);

% find feature template to match against test vector
template_features = [];
spots = cell(feature_count,1);
spots2 = cell(feature_count,1);
anno_lengths = zeros(feature_count,1);
for i=1:feature_count
    new_data = csvread( ['template_' test_file_names{i}] );
    template_features{i} = featureBuild(new_data,sample_rate,0,...
        length(new_data(:,1)),1);
    anno_lengths(i) = mode( test_annotations(anno_starts(:,1)==i,3) - ...
        test_annotations(anno_starts(:,1)==i,2) );
    spots{i} = cell2mat(arrayfun(@colon,...
        test_annotations(anno_starts(:,1)==i,2)',...
        test_annotations(anno_starts(:,1)==i,3)','UniformOutput',0));
    spots2{i} = cell2mat(arrayfun(@colon,...
        test_annotations(anno_starts(:,1)==i,2)'-round(anno_lengths(i)/2),...
        test_annotations(anno_starts(:,1)==i,3)'+round(anno_lengths(i)/2),...
        'UniformOutput',0));
    valid_regions(spots{i},i) = -10;
    false_pos_clear(spots2{i},i) = - 10;
end

% at this point there is the raw test vector with the templates we wish to
% match against the vector. as the test vector comes with annotations, it
% is known how many should match. this allows for sensitivity/specificty to
% be measured from the process.

% featureFinderAuto returns a value of 5 when a feature is matched, the
% columnds indicate the feature being matched to the data. this value can
% then be used to determine false positives, true positives and false
% negatives later in the program
feature_matches = featureFinderAuto(test_data,template_features,sample_rate);

figure('name','visual results','numbertitle','off');
subplot(311);plot(test_data);
xlim([0 length(test_data) ]);xlabel(' raw data ');
subplot(312);plot(valid_regions,'linewidth',2);
axis([0 length(valid_regions) min(min(valid_regions))-1 1]);
xlabel(' annotation labels ');
% sub the sub?
subplot(313);plot(feature_matches);
axis([0 length(feature_matches) min(min(feature_matches))-1 max(max(feature_matches))+1 ]);
xlabel(' matched features ');

% analysis of matches
feature_punch_card = zeros(size(valid_regions));
true_positive = zeros(feature_count,1);
false_negative = true_positive;
false_positive = true_positive;
hit = false_negative;
miss = hit;
hit_window = zeros(feature_count,length(test_annotations));
overlap = miss;
reduction = overlap;
b = (1 / 50) * ones(1,50);

for i=1:feature_count
    
    feature_punch_card(:,i) = feature_matches(:,i) + valid_regions(:,i);
    % collect all regions flagged as matches that aren't. compare flagged
    % regions to true regions and returned percent overlap and/or percent
    % useless
    [indx_matches,~] = find(feature_matches(:,i)==3);
    overlap(i) = numel(intersect(indx_matches,spots{i}))/numel(spots{i});
    reduction(i) = numel(indx_matches)/numel(feature_punch_card);
    
    % better way to find true positives and false negatives
    pos_starts = test_annotations( anno_starts(:,1)==i, 2);
    pos_stops = test_annotations( anno_starts(:,1)==i, 3);
    
    t = 1;
    for k=1:length(pos_starts)
        region_of_interest = feature_matches(pos_starts(k):pos_stops(k),i);
        % regions flagged by learning algorithm are set to a value of 3
        hit_window(i,t) = sum( region_of_interest==3 );
        if( hit_window(i,t) > 0 )
            hit(i) = hit(i) + 1;
        else
            miss(i) = miss(i) + 1;
        end
        t = t + 1;
        feature_matches(pos_starts(k):pos_stops(k),i) = -20;
    end
    true_positive(i) = hit(i);
    false_negative(i) = miss(i);
    % find false positives by comparing the length of the hit against the
    % width of the annotation. if the width is larger than twice the
    % annotation length declare a false positive. trakcing only number, not
    % location
    false_check = feature_matches(:,i) + false_pos_clear(:,i);
    false_check_int = [0 false_check' 0];
    false_check_int( false_check_int > 0 ) = 3;
    false_check_int( false_check_int < 0 ) = 0;
    false_check_diff = diff(false_check_int);
    negg = find( false_check_diff < 0 );
    poss = find( false_check_diff > 0 );
    true_diff_x = negg-poss;
    false_positive(i) = sum(true_diff_x > 2*anno_lengths(i));
    
end
% determine sensitivity of process and others
sensitivity = true_positive ./ ( true_positive + false_negative );
FDR = false_positive ./ (true_positive+false_positive);

end