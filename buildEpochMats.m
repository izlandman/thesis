% generate .mat files of epoch data, this should only need to be run once
% to generate the neccesary epoch files. it will auto generate a folder and
% handle file management of deletiong/creationg of folders and files.

% INPUTS: POOL_DATA must be a string that points to the folder of the
% subject .edf files. This is the only required field when called.
% Adjusting the other parameters must be done in an all or none fashion.

% OUTPUTS: This function saves .mat files of each subject's epoch data

function buildEpochMats(pool_data,butter_order,butter_low,butter_high,...
    analysis_frame,analysis_shift,block_time,epoch_time)

close all;

if nargin == 1
    fltr.butter_order = 5;
    fltr.butter_low = 0.5;
    fltr.butter_high = 50;
    mf.cc_num = 13;
    % in milliseconds
    mf.analysis_frame = 1000;
    mf.analysis_shift = 500;
    mf.pre_emp_coef = 0.97;
    mf.range = [0.5 80];
    mf.banks = 21;
    mf.liftering_param = 22;
    % in seconds
    mf.block_time = 10;
    mf.epoch_time = 1.5;
else
    fltr.butter_order = butter_order;
    fltr.butter_low = butter_low;
    fltr.butter_high = butter_high;
    mf.cc_num = cc_num;
    % in milliseconds
    mf.analysis_frame = analysis_frame;
    mf.analysis_shift = analysis_shift;
    mf.pre_emp_coef = pre_emp_coef;
    mf.range = range;
    mf.banks = banks;
    mf.liftering_param = liftering_param;
    % in seconds
    mf.block_time = block_time;
    mf.epoch_time = epoch_time;
end

target_data = '';

new_directory = strcat(datestr(date),'_',pool_data,'_epoch');

% verify the directory doesn't exist already
if( exist(new_directory,'dir') == 7 )
    prompt = 'Directoy already exists. Delete and replace?[y/n]';
    response = input(prompt,'s');
    if( response == 'y' || response == 'Y' )
        rmdir(new_directory,'s');
    else
        error('Cannot make new directory. User aborted.');
    end
else
    mkdir(new_directory);
end

% read in the EDF data and setup filter
% sort through pool to setup for file comparison
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_data,target_data,fltr);

for i=1:length(pool.data)
    pool.feature_set(i) = featureFinderSlim(pool.data{i},pool.sample_rate(i),mf.block_time,mf.epoch_time);
    pool.feature_variables{i} = frequencyPeakFinder(pool.feature_set(i));
    epochs = pool.feature_variables{i};
    pool_save = strcat(new_directory,'\','epochs_model_',num2str(i),'.mat');
    save(pool_save,'epochs');
    disp( ['Saving ',num2str(i),' of ', num2str(length(pool.data)) ] );
end


end