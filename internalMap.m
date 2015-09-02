function result = internalMap(data,feature)

for t=1:length(feature)
    
    % now that all the features are generated, time to group them together
    match_index = zeros(num_samples,num_samples,channels);
    match_weights = [1 1 1 1 1];
    for q=1:channels
        for r=1:samples
            for i=r:samples
                match_index(r,i,q) = sum(([result{t}(r,:,q)-result{t}(i,:,q)]==0).*match_weights)/5;
            end
        end
    end
end
% group matching samples together by index
count = 0;
grouping = [];
index = (1:samples);
while count < samples
    [y,r] = find( match_index(index(1),:)==1 );
    % remove index if matched
    A = ismember(index,r);
    index(A) = [];
    count = count + sum(y);
    grouping{end+1} = r;
end