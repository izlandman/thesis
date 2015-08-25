% given the files, return a test vector for testing along with annotated
% locations (in sample points) of where the identified features are located

function generateFeatureVector(...
    feature_file_list,feature_count,spacing_max,test_name,warp_factor)

num_feature_files = length(feature_file_list);

if( length(feature_count) < num_feature_files )
    feature_count = feature_count*ones(num_feature_files,1);
end

% for each feature being used in the vector, hold how many annotations
% should be found in that file
feature_annotation_list = cell(num_feature_files,1);
annotation_parameters = zeros(num_feature_files,2);
annotation_data = cell(num_feature_files,1);

random_features = [];
sample_count = zeros(num_feature_files,1);

for i=1:num_feature_files
    feature_annotation_list{i} = ['ann_' feature_file_list{i}];
    annotation_parameters(i,1) = feature_count(i);
    annotation_data{i} = csvread(feature_annotation_list{i},1,0);
    % assumes each feature is annotated with start and stop point, removes
    % one to handle sample rate being first column of data
    annotation_parameters(i,2) = ( length(annotation_data{i}) - 1 ) / 2;
    % randomize order of features part one
    random_features = [random_features i*ones(1,feature_count(i))];
    sample_count(i) = length(annotation_data{i}(:,1));
end

% randomize order of features part two
random_features = random_features(:,randperm(size(random_features,2)));

sample_rate = annotation_data{1}(1);
total_events = sum( annotation_parameters(:,1).*sample_count(:) );
% record start and stop time relative to feature_test_vector
event_windows = zeros(total_events,length(annotation_data{1}));

% stitch together the sample signals
result = [];
filler_spacing = [];
if( spacing_max ~= 0 )
    transition_spacing = spacing_max/2 + randi(spacing_max);
else
    transition_spacing = 10;
end
filler = sin( linspace(0,3*pi/2,transition_spacing) ) + ...
    cos( linspace(0,pi,transition_spacing) );
total_samples = 0;
i_end = 0;
for i=1:sum(feature_count)
    i_start = (i_end + 1);
    i_end = i_start - 1 + sample_count(random_features(i));
    new_data = csvread(feature_file_list{random_features(i)},1,0);
    % new_data is the template, if it needs to be stretched or shrunk. do
    % it here before it gets put into the results. don't forget to update
    % the annotation to match the change in size of the measured feature
    event_windows(i_start:i_end,1) = random_features(i);
    if( warp_factor > 0 )
        [warped_data,warped_annotation] = timeWarpData(new_data,...
            annotation_data{random_features(i)}(:,2:end));
    else
        warped_data = new_data;
        warped_annotation = annotation_data{random_features(i)}(:,2:end);
    end
    if( i > 1 )
        init_values = result(end,:);
        end_values = warped_data(1,:);
        deltas = ( end_values - init_values ) ./ transition_spacing;
        filler_spacing = [deltas' * (1:transition_spacing) + ...
            repmat(filler,3,1) + repmat(init_values',1,transition_spacing)]';
        event_windows(i_start:i_end,2:end) = transition_spacing + ...
            total_samples + warped_annotation;
        total_samples = total_samples + length(warped_data(:,1)) + ...
            transition_spacing;
    else
        event_windows(i_start:i_end,2:end) = total_samples + ...
            warped_annotation;
        total_samples = total_samples + length(warped_data(:,1));
    end
    result = [ result ; filler_spacing; warped_data ];
end

save_file_1 = [test_name '_raw.dat'];
dlmwrite(save_file_1,result,'delimiter',',');

save_file_2 = [test_name '_ann.dat'];
fid = fopen(save_file_2,'w+');
for i=1:length(feature_file_list)
    fprintf(fid,'%s \t',feature_file_list{i});
end
fprintf(fid,'\n');
for i=1:length(sample_count)
    fprintf(fid,'%d \t',sample_count(i));
end
fprintf(fid,'\n');
fprintf(fid,'%d \t',sample_rate);
fprintf(fid,'\n');
dlmwrite(save_file_2,event_windows,'delimiter',',','-append');

end