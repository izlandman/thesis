% given a directory of EDF files to be studied, prepare to process by
% determing the number of files in the directory. then gather the first set
% of data to be broken into overlapping windows given the desire channel
% listing

% varargin's first pass should be feature(s) to be computed, the second
% argument will be any special channel selection

function initializeMap(folder_path,varargin)

% percentage from 0 to 100, but i hope nobody ever picks 100.
window_overlap = varargin{2};

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
feature_list = varargin{1};

% channel map will fill the first column of the cell with an n by m array
% indicating the match strength between that sample and all other samples.
% the second column will indicate which feature is used for this comparison
results = cell(file_count,major_features);
header_tag = zeros(file_count,3);
for i=1:file_count
    [data,header] = lab_read_edf(folder_list{i});
    if (nargin > 3)
        data = data(varargin{3},:);
    end
    % pass data to the appropriate feature builders
    for k=1:major_features
        % pass data, sampling rate, feature to be computed. return it to
        % the channel map cell
        results{i,k} = buildMapFeature(data,header.samplingrate,...
            window_overlap,feature_list(k));
        % build a proper header file
        header_tag(i,:) = [feature_list(k) header.samplingrate window_overlap];
    end
end

% now that all the features are generated, save them for use with further
% analysis as Matlab may not be the best place to start building large
% state diagrams of feature transitions

switch feature_list
    case 1
        feat_type = 'band';
    case 2
        feat_type = 'warp';
end

now_folder = ['../' datestr(now,'yyyy_mm_dd_HH_MM_SS') '/' feat_type];
mkdir(now_folder);
% file names unique to each file in the folder
for i=1:file_count
    [~,name,~] = fileparts(folder_list{i});
    for k=1:length(major_features)
        file_name_save = [now_folder '/' name '_' num2str(varargin{3}(end)) '_.mat'];
        final_output = [ header_tag(i,:) ; results{i,k}];
        save(file_name_save,'final_output');
%         dlmwrite(file_name_save,header_tag(i,:));
%         dlmwrite(file_name_save,results{i,k},'-append');
    end
end

end