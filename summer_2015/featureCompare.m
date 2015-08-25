% perform least squares calculation on two sets of time, fft, psd data to
% build distance measurements between the two annotations. given the time
% signal is likely to vary in size, one will need to walk through the other
% perhaps taking the smallest error found as true? the fft and psd data
% should be of the same size for a one to one comparison.

% input is assumed to be pairs grouped by source:
% time_1,fft_1,psd_1,time_2,fft_2,psd_2
function result = featureCompare(new_feat,old_feat,cho_feat)

result = zeros(length(cho_feat),1);

for i=1:length(cho_feat)
    result(i) = squareMath(new_feat.features{cho_feat(i)},...
        old_feat.features{cho_feat(i)});
end

end

function result = squareMath(data1,data2)
length1 = max( size(data1) );
signals = min( size(data1) );
length2 = length(data2);
% normalize the data so the amplitudes are worked as relative changes and
% not absolute

data1_std = std(data1);
data2_std = std(data2);

data1_scaled = bsxfun(@rdivide,data1,data1_std);
data2_scaled = bsxfun(@rdivide,data2,data2_std);

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