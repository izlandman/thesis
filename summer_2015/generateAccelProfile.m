% given a folder of cleaned/prepped accelerometer data piece the files
% together 'randomly' to generate a somewhat unique test case to be
% analayzed. 
function result = generateAccelProfile(file_name,segments,fill_distance)

result = [];
filler_spacing = [];
filler = 0.2*sin( linspace(0,100*pi,fill_distance) );
for q=1:segments
    new_data = csvread(file_name,1,0);
    % smooth transition as best as possible
    if( q > 1 )
        init_values = result(end,:);
        end_values = new_data(1,:);
        deltas = ( end_values - init_values ) ./ fill_distance;
        filler_spacing = [deltas' * (1:fill_distance) + repmat(filler,3,1)...
            + repmat(init_values',1,fill_distance)]';
    end
    result = [ result ; filler_spacing ; new_data ];
end

end