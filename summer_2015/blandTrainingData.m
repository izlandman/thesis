% as some data may have been selected within coords, take data not being
% classified to train the classifier against.
function result = blandTrainingData(coords,data)

if( isempty(coords) )
    result = data;
else
    used_data = zeros(length(data(:,1)),1);
    index_data = 1:length(data(:,1));
    for i=1:2:length(coords(:,1))
        used_data = used_data + ( coords(i,1) <= index_data & index_data <= coords(i+1,1) )';
    end
    
    result = data(~used_data==1,:);
end

end