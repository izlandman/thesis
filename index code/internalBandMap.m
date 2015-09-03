function result = internalBandMap(data)

[num_samples,window,channels] = size(data);

% now that all the features are generated, time to group them together
match_index = zeros(num_samples,num_samples,channels);
match_weights = [1 1 1 1 1];
for q=1:channels
    for r=1:num_samples
        for i=r:num_samples
            match_index(r,i,q) = sum(([data(r,:,q)-data(i,:,q)]==0).*match_weights)/5;
        end
    end
end

% group matching samples together by index
result = cell(channels,1);
% column 1 is ID, column 2 is following group, column 3 is next group,
% columdn 4 is % likelihood of the 2 series occuring, 5 is % likelihood of
% the 3 series occuring
tracking_matrix = zeros(num_samples,5,channels);

for k=1:channels
    count = 0;
    grouping = [];
    index = (1:num_samples);
    while count < num_samples
        [y,r] = find( match_index(index(1),:)==1 );
        % remove index if matched
        A = ismember(index,r);
        index(A) = [];
        count = count + sum(y);
        grouping{end+1} = r;
        % assign group number to all associated samples
        tracking_matrix(r,1,k) = length(grouping);
    end
    result{k} = grouping;
end

[~,num_groups] = size(grouping);
% build rows of the series data. column one is the class label and then row
% 2 is what follows row 1 and row 3 is what follows from 2
tracking_matrix(1:end-1,2) = tracking_matrix(2:end,1);
tracking_matrix(1:end-2,3) = tracking_matrix(3:end,1);

transitions = cell(num_groups,channels);
transition_error_cor = [131 0.5 0.3]';
for k=1:channels
    for i=1:num_groups
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
        % there will always be a diagonal zero give it matches to itself,
        % the key is to find the off diagonal matches which tell you how
        % likely that condition is to occur again in the group
        tracking_matrix(index,4,k) = sum(score1==0)/index_count;
        tracking_matrix(index,5,k) = sum(score2==0)/index_count;
    end
end

end