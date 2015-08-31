% given a directory of EDF files to be studied, prepare to process by
% determing the number of files in the directory. then gather the first set
% of data to be broken into overlapping windows given the desire channel
% listing

% varargin's first pass should be feature(s) to be computed, the second
% argument will be any special channel selection

function initializeMap(folder_path,varargin)

% assume we wish to find .edf files to process
folder_data = getAllFiles(folder_path);
folder_list = {};

for i=1:length(folder_data)
    [~,~,ext] = fileparts(folder_data{i});
    if( ( strcmp(ext,'.edf') || strcmp(ext,'.EDF') ) )
        folder_list{end+1} = folder_data{i};
    end
end

% for each file in the folder, build the model of it with internal mapping
% to matching samples
file_count = length(folder_list);
major_features = length(varargin{1});
% channel map will fill the first column of the cell with an n by m array
% indicating the match strength between that sample and all other samples.
% the second column will indicate which feature is used for this comparison
channel_map = cell(file_count,major_features);
for i=1:file_count
    [data,header] = lab_read_edf(folder_list{i});
    if (nargin > 2)
        data = data(varargin{2},:);
    end
end


end