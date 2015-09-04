% The annotation files for the EEGMMIDB data are not that helpful. Build
% proper annotation files to help with matching samples to annotations to
% test the validity of matched groups. given a folder name it finds all the
% edf files and writes annotation files into that same folder from those
% found edf files
function annotationFileBuilder(folder_path,save_path)

% assume we wish to find .edf files to process
folder_data = getAllFiles(folder_path);
folder_list = {};

for i=1:length(folder_data)
    [~,~,ext] = fileparts(folder_data{i});
    if( ( strcmp(ext,'.edf') || strcmp(ext,'.EDF') ) )
        folder_list{end+1} = folder_data{i};
    end
end

% for each found file, build an annotation matrix of sample number and
% event type to be used for matching to the results
file_count = length(folder_list);

% first two files are calibration, no annotations
for i=3:file_count
    % rdann is a function from the physio toolbox, remember to site their
    % paper if you publish from this data. a1 contains sample number, f1
    % contains event case
    [a1,~,~,~,~,f1] = rdann(folder_list{i},'event');
    filtered_events_1 = cellfun(@(x) x{1}(2),f1,'UniformOutput',false);
    filtered_events_2 = cellfun(@(x) x{1}(end-2:end),f1,'UniformOutput',false);
    step_1 = cell2mat(filtered_events_1);
    step_2 = str2num(step_1);
    step_3 = cell2mat(filtered_events_2);
    step_4 = str2num(step_3);
    output_matrix = [a1 a1+step_4*160 step_2];
    % build new file name for annotation and save matrix to it
    [~,name,~] = fileparts(folder_list{i});
    annot_name = [ save_path '/' name '_ANN.ann'];
    dlmwrite(annot_name,output_matrix);
end

end