function [result,tracking_matrix,num_groups] = formGroups(data)

[rowz,~,channels] = size(data);
tracking_matrix = zeros(rowz,7,channels);
result = cell(channels,1);
num_groups = zeros(channels,1);

for k=1:channels
    count = 0;
    grouping = [];
    index = (1:rowz);
    while count < rowz
        [y,r] = find( data(index(1),:)==1 );
        % remove index if matched
        A = ismember(index,r);
        index(A) = [];
        count = count + sum(y);
        grouping{end+1} = r;
        % assign group number to all associated samples
        tracking_matrix(r,1,k) = length(grouping);
    end
    result{k} = grouping;
    num_groups(k) = length(grouping);
end

end