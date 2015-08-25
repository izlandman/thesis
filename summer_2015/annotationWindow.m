function [feature_coords] = annotationWindow(raw_data,window_count,...
    sample_rate,data_length)
% feature storage, to hold good and bad features. this is problematic
% because I believe this should be a class/object with specific fields that
% could be indexed without the use of a cell array. this would allow them
% to indexed by type of feature or duration or and of their other values.
% AS SUCH I BUILT WHAT I THOUGHT I NEEDED, LET'S HOPE THIS WORKS.
true_features = {};
feature_coords = [];
annotation_LDA_model = [];

window_start = 1;
window_end = window_start + window_count - 1;

% Find how many columns of data were fed in and plot those for analysis
data_channels = length(raw_data(1,:));
yY = zeros(window_count,data_channels);
h = zeros(data_channels,1);
calc_h = zeros(data_channels,1);

base_fig = figure('name','Annotation Window','NumberTitle','off');
xX = linspace(0,window_end/sample_rate,window_count);

for i=1:data_channels
    yY(:,i) = raw_data(window_start:window_end,i);
    subplot(data_channels,2,i*2-1);
    h(i) = plot(xX,yY(:,i));grid on;
    title('Data to Annotate');
    ylabel(['Signal ',num2str(i)]);
    xlabel('Time (s)');
    subplot(data_channels,2,i*2);
    calc_h(i) = plot(xX,yY(:,i));grid on;
    title('Algorithm''s Best Guess');
    ylabel(['Signal ',num2str(i)]);
    xlabel('Time (s)');
end

% ascii escape is 27
% ascie spacebar is 32
data_in = 0;

while window_end < data_length
    
    % input function
    [data_in,ordered_time_coords,feature_coords] = gatherUserInput(data_in,feature_coords);

    % if annotations are present normalize their window size and then build
    % the feature vectors associated with the time data
    new_features = {};
    if( sum(sum(ordered_time_coords)) ~= 0 )
        new_features = featureSet(raw_data,ordered_time_coords,sample_rate,...
            data_length);
    else
        disp('no annotations');
    end
    
    % determine if new features found are new or match old feature
    true_features = distillFeature(new_features,true_features);
    
    % continous dynamic time warping data
    true_feat_leng = length(true_features);
    test_1 = cell(true_feat_leng,1);
    for y=1:true_feat_leng
        test_1{y} = true_features{y}.source(:,3);
    end
    [warping_matrix_1, test_2] = testCdtw(test_1);
    for y=1:true_feat_leng
        true_features{y}.features{1} = test_2{y};
    end
    
% ----------------------------------------------------------------LDA UP IN
    
    % build bland/null features to train annotations against, only if
    % window contained an annotated feature!
    if( ~isempty(new_features) )
        bland_features = buildBlandData(ordered_time_coords,sample_rate,...
            yY,window_start,window_end);
    end
    % run something like Sid's LDA given the annotations and bland data as
    % your two classes. the model will be unique for each channel, which
    % maybe a problem given that the features should be linked across
    % channels and not separated!
    if( ~isempty(true_features)  )
        annotation_LDA_model = buildLdaModel(true_features,bland_features);
    end
    
    % with the annotated data in hand, this is where the software should
    % search the next window for features before presenting them to the
    % user. if strong feature matches are found categorize accordingly and
    % move to the next window. if poor matches are found present the window
    % to the user so the software may continue learning.
    window_start = window_end + 1;
    window_end = window_start + window_count - 1;
    if( window_end > data_length )
        window_end = data_length;
    end
    
    % with features normalized to the sample rate as the smallest allowable
    % time frame, work through the new window period to find potentially
    % matches
    new_data = featureFinder(raw_data,window_start,window_end,...
        sample_rate,data_length,true_features,annotation_LDA_model);
    if( window_end < data_length)
        assistantWindow(raw_data,window_start,window_end,sample_rate,...
            window_count,new_data,h,calc_h);
    end
end

end