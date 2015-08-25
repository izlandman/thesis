function [data_in,ordered_time_coords,feature_coords] = gatherUserInput(data_in,feature_coords)

while( data_in == 0 )
    disp('start');
    % set(0,'currentfigure',base_fig);
    try
        disp('trying');
        [x,y,button] = ginput(1);
        y
    catch
        disp('ginput error caught');
        return
    end
    if( button == 32 )
        data_in = 1;
        disp('Spacebar pressed, exiting input phase.');
    elseif( button == 1 || button == 3)
        % annotation of feature
        feature_coords = cat(1, feature_coords, [x y button]);
    else
        disp('This isn''t good, input isn''t recognized.');
    end
end
% reset input control
data_in = 0;

% ensure coordinates are in the right order. assume that everything
% comes in pairs of two, but the pairs may be out of order
ordered_time_coords = sortTimeCoordinates(feature_coords);
feature_coords = [];

end