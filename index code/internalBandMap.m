function result = internalBandMap(data,file_name,sample_rate,window_overlap)

[num_samples,window,channels] = size(data);

% now that all the features are generated, time to group them together
match_weights = [1 1 1 1 1];
match_index = matchFeatureWeights(data,match_weights);

% column 1 is ID, column 2 is following group, column 3 is next group,
% columds 4 through 6 represent the % occurance of that series
[result,tracking_matrix,num_groups] = formGroups(match_index);

% build rows of the series data. column one is the class label and then row
% 2 is what follows row 1 and row 3 is what follows from 2
tracking_matrix(1:end-1,2) = tracking_matrix(2:end,1);
tracking_matrix(1:end-2,3) = tracking_matrix(3:end,1);

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['C:/_ward/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[event_tags, anno_listing] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);
grouped_data = zeros(max(num_groups),4,channels);

% newer idea, build cell that groups tails of each main group
tail_groups = cell(max(num_groups),channels);
annotation_groups = tail_groups;
for k=1:channels
    for i=1:num_groups(k)
        % provides index of matching groups
        [group_index,~] = find( tracking_matrix(:,1) == i );
        % don't let the group_index be pushed outside the element count of
        % the vector
        too_far = group_index + 3;
        group_index( too_far > num_samples ) = [];
        tail_groups{i,k} = [ tracking_matrix(group_index,1,k) ... 
            tracking_matrix(group_index+1,1,k) tracking_matrix(group_index+2,1,k) ...
            tracking_matrix(group_index+3,1,k) ];
        annotation_groups{i,k} = [ anno_listing(group_index,k) ... 
            anno_listing(group_index+1,k) anno_listing(group_index+2,k) ...
            anno_listing(group_index+3,k)];
    end
end

% With annotation_groups, the same matchFeatureWeight and formGroups can be
% called to figure out what variations exist in the group clusters relative
% to the annotations. This should provide one map of features against a map
% of annotations linked by how the features are weighted. This is probably
% where writing something in C/C++ is going to help as each cluster for
% each channel needs to be iterated.


transition_error_cor = [131 0.5 0.3]';
for k=1:channels
    for i=1:num_groups(k)
        % scan through each of the initial state transitions
        index = result{k}{i};
        index_count = length(index);
        score1 = zeros(index_count,index_count);
        score2 = score1;
        for r=1:index_count
            score1(r,:) = (tracking_matrix(index,1:2,k) - ...
                repmat(tracking_matrix(index(r),1:2,k),index_count,1))*transition_error_cor(1:2);
            score2(r,:) = (tracking_matrix(index,1:3,k) - ...
                repmat(tracking_matrix(index(r),1:3,k),index_count,1))*transition_error_cor;
        end
        % for a given group, find the total matches to each potential event
        % marker
        for q=1:length(event_tags)
            tracking_matrix(index,3+q,k) = sum( anno_listing(index,k) == event_tags(q) );
            grouped_data(i,1+q,k) = sum( anno_listing(index,k) == event_tags(q) );
        end
        % there will always be a diagonal zero give it matches to itself,
        % the key is to find the off diagonal matches which tell you how
        % likely that condition is to occur again in the group
        tracking_matrix(index,4,k) = index_count/num_samples;
        grouped_data(i,1,k) = index_count/num_samples;
        tracking_matrix(index,5,k) = sum(score1==0)/index_count;
        tracking_matrix(index,6,k) = sum(score2==0)/index_count;
    end
    percentages = bsxfun(@rdivide,grouped_data(:,2:end,k),sum(grouped_data(:,2:end,k),2));
    grouped_data = [ grouped_data percentages ];
end

% build layer % maps
states = length(tail_groups{1,1}(1,:));
state_percent_matrix = zeros(num_groups,num_groups,channels,states);
for k=1:channels
    for n=2:states
        for i=1:num_groups
            tail_match = tail_groups{i,k}(:,n);
            for r=1:num_groups
                state_percent_matrix(i,r,k,n) = sum( tail_match == r ) / num_groups;
            end
        end
    end
end

result = state_percent_matrix;

end