% No idea where this is used or why it was written. Less learned I suppose?

% stacks channel data turning it into 2D matrix
function data_output = featureStacker(data_input)
events = length(data_input);
data_output = cell(1,events);

for i=1:events
    channels = length(data_input{i}(:,1));
    stacks = length(data_input{i}(1,:));
    for k=1:stacks
        start = 1 + (channels*k-1);
        stop = start + channels -1;
        data_output{i}(start:stop) = data_input{i}(:,k); 
    end
end
end