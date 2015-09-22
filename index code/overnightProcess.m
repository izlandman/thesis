function overnightProcess(directory)

file_listing = dir(directory);

for i=1:length(file_listing)
    % operate only on files in the folder, not directories
    [path,name,ext] = fileparts(file_listing(i).name);
    if( file_listing(i).isdir == 0 && strcmp(ext,'.mat'))
        file_to_handle = file_listing(i).name;
        % call internal map to compute and save DTW matrix
        file_name = [pwd '\' directory '\' file_to_handle];
        internalMap(file_name);
    end
end
end