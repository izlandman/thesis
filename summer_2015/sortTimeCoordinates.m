function result = sortTimeCoordinates(coords)

if( isempty(coords) )
    result =zeros(2,3);
else
    
    result = coords;
    
    num_coords = length(coords(:,1));
    index_offset = 1:2:num_coords;
    
    odd_base = mod( (1:num_coords), 2) == 1;
    even_base = ~odd_base;
    
    correction = coords(odd_base,1) > coords(even_base,1);
    
    result( index_offset(correction),: ) = coords( index_offset(correction) + 1,:);
    result( index_offset(correction) + 1,:) = coords( index_offset(correction),: );
    
end

end