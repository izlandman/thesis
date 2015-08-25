% analyze the psd data. rarely used.

function psdHist(psd_directory)

% build psd file list, cells/strings
psd_file_list = numericFileList(psd_directory,'PSD_model_');
psd_num_files = length(psd_file_list);

psd_data = cell(psd_num_files,1);

for i=1:psd_num_files
    psd_data{i} = load(psd_file_list{i});
end

end