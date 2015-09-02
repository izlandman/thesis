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
    end
    result{k} = grouping;
end

end