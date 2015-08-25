% will find files associated with subject number

% INPUTS: based upon the number of inputs unique sets of data are returned.
% with only ONE input the files returned are the valid_gm file that checks
% for full GMMs from the data. TWO inputs returns an entire epoch file or
% gmm file. THREE inputs returns a band specific epoch file. FOUR inputs
% returns a band and feature specific EPOCH file.

% OUTPUTS: DATA_FILES will always be a cell with an unknown set of strings
% linking to the found folder names

function data_files = fileFinderFull(varargin)
folder_name = varargin{1};
if( nargin == 4)
    band = varargin{4};
    feature = varargin{3};
    subject_number = varargin{2};
    number_of_folders = length(folder_name);
    data_files = cell(number_of_folders,1);
    for i=1:number_of_folders
        target_name_search = [folder_name{i},'\*_',num2str(subject_number),'.*'];
        target_file = dir(target_name_search);
        data_files{i} = importdata( ['.\',folder_name{i},'\',target_file.name] );
        data_files{i} = squeeze(data_files{i}(:,feature,band,:));
    end
    
elseif( nargin == 3)
    feature = varargin{3};
    subject_number = varargin{2};
    number_of_folders = length(folder_name);
    data_files = cell(number_of_folders,1);
    for i=1:number_of_folders
        target_name_search = [folder_name{i},'\*_',num2str(subject_number),'.*'];
        target_file = dir(target_name_search);
        data_files{i} = importdata( ['.\',folder_name{i},'\',target_file.name] );
        data_files{i} = squeeze(data_files{i}(:,feature,:,:));
    end
elseif( nargin == 2)
    subject_number = varargin{2};
    number_of_folders = length(folder_name);
    data_files = cell(number_of_folders,1);
    for i=1:number_of_folders
        target_name_search = [folder_name{i},'\*_',num2str(subject_number),'.*'];
        target_file = dir(target_name_search);
        [~,index] = max([target_file.bytes]);
        data_files{i} = importdata( ['.\',folder_name{i},'\',target_file(index).name] );
    end
elseif( nargin == 1)
    number_of_folders = length(folder_name);
    data_files = cell(number_of_folders,1);
    for i=1:number_of_folders
        target_name_search = [folder_name{i},'\*','valid_gm','*'];
        target_file = dir(target_name_search);
        [~,index] = max([target_file.bytes]);
        data_files{i} = importdata( ['.\',folder_name{i},'\',target_file(index).name] );
    end
else
    disp('file finder error');
end
end