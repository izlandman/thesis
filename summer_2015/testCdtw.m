function [result,input_data] = testCdtw(input_data)

feature_count = length( input_data );
distance_map = zeros(feature_count,feature_count);

for r=1:feature_count-1
    for t=r+1:feature_count
        [dist_btwn, dist_accum,~, ~, new_r, new_t ] = cdtw2(input_data{r},...
            input_data{t},0);
        input_data{t} = new_t;
        if( isnan(dist_btwn) == 0 )
            distance_map(r,t) = dist_btwn;
        elseif( sum(isnan(new_r))>0 && sum(isnan(new_t))>0 )
            distance_map(r,t) = sum( (remove_nan(new_r) - remove_nan(new_t)).^2 );
        elseif( sum(isnan(new_t))>0 )
            distance_map(r,t) = sum( (new_r - remove_nan(new_t)).^2 );
        else
            distance_map(r,t) = sum( (remove_nan(new_r) - new_t).^2 );
        end
    end
    input_data{r} = new_r;
end

result = distance_map;

end

function result = remove_nan(input_vector)
nan_shift = 2;
result = input_vector;
nan_index = find( isnan(input_vector) == 1 );

for y=1:length(nan_index)
    new_value = nanmean( input_vector( nan_index(y)-nan_shift : nan_index(y)+nan_shift ) );
    result(nan_index(y)) = new_value;
end

end