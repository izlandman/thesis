function result = computeResiduals(data1,data2)
[length1,signals] = size(data1);
length2 = length(data2);
% normalize the data so the amplitudes are worked as relative changes and
% not absolute

data1_scaled = zscore(data1);
data2_scaled = zscore(data2);

if( length1 == length2 )
    result = (1/length1) * sum( ( data1_scaled - data2_scaled ).^2 );
else
    offset = length1 - length2;
    sSquares = zeros(abs(offset),signals);
    if( offset > 0 )
        % length1 exceeds length2
        stop = length2;
        for i=1:offset
            sSquares(i,:) = (1/length2) * sum( (data1_scaled(i:stop,:) - data2_scaled).^2 );
            stop = length2 + i; 
        end
    elseif( offset < 0 )
        % length2 exceeds length1
        stop = length1;
        for i=1:abs(offset)
            sSquares(i,:) = (1/length1) * sum( (data2_scaled(i:stop,:) - data1_scaled).^2 );
            stop = length1 + i;
        end
    end
    result = min(sSquares);
end
end