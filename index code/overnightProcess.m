function overnightProcess(directory)

file_listing = dir(directory);

for i=10:length(file_listing)
    % operate only on files in the folder, not directories
    [path,name,ext] = fileparts(file_listing(i).name);
    if( file_listing(i).isdir == 0 && strcmp(ext,'.mat') && ...
            ~strcmp(name(6:7),'01') && ~strcmp(name(6:7),'02'))
        file_to_handle = file_listing(i).name;
        % call internal map to compute and save DTW matrix
        file_name = [pwd '\' directory '\' file_to_handle];
        internalMap(file_name);
    end
end
end