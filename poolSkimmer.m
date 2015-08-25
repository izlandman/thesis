% sort through all other files to find EDF records, this should be called
% only when building the inital model sets to generate epochs.mat and
% gmm.mat, a very useful function for finding all the files necessary.

function [pool_data_out,pool_annotations,pool_durations,pool_duration,...
    pool_sample_rate] = poolSkimmer(pool,target,fltr,rndm)
if( nargin == 3 )
    rndm = 0;
end
pool_file_list = getAllFiles(pool);
[target_path,target_name,target_ext] = fileparts(target);
pool_edf_list = {};
% only match .EDF and .edf files. DO NOT match with target file
for i=1:length(pool_file_list)
    [path,name,ext] = fileparts(pool_file_list{i});
    if( ( strcmp(ext,'.edf') || strcmp(ext,'.EDF') ) && ~strcmp(target_name,name) )
        pool_edf_list{end+1} = pool_file_list{i};
    end
end

% build feature vectors of each sample. this for loop is a killer. figure
% out a way around it?
pool_edf_list_length = length(pool_edf_list);
pool_data_out = cell(1,pool_edf_list_length);
pool_annotations = cell(1,pool_edf_list_length);
pool_durations = cell(1,pool_edf_list_length);
pool_duration = zeros(1,pool_edf_list_length);
pool_sample_rate = zeros(1,pool_edf_list_length);
for i=1:pool_edf_list_length
    display( ['Processing file: ',num2str(i),' of ',num2str(pool_edf_list_length), ': ', pool_edf_list{i}] )
    [pool_classes,p_durations,pool_data,sample_rate,p_duration] = ...
        filePrep(pool_edf_list{i}, fltr,rndm);
    pool_data_out{i} = pool_data;
    pool_annotations{i} = pool_classes;
    pool_durations{i} = p_durations;
    pool_duration(i) = p_duration;
    pool_sample_rate(i) = sample_rate;
end
end
