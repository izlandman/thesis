% given a string and directory, return all matched full file names in a
% cell array. if no directory is specified, use the current directory.
% searches down entire directory tree.
function result = matchFileName(varargin)

switch nargin
    case 1
        directory_start = cd;
        match_string = varargin{1};
    case 2
        directory_start = varargin{2};
        match_string = varargin{1};
    otherwise
        disp('Incorrect input arguments! String to match followed by directory (optional).');
end

file_listing = getAllFiles(directory_start);
matched_files = strfind(file_listing,match_string);

index = ~ cellfun(@isempty,matched_files);

result = file_listing(index);

end