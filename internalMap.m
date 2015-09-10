function internalMap(file_name)

data = load(file_name);
data_header = data.final_output{1};
data = data.final_output{2};
[path,name,ext] = fileparts(file_name);
feature = data_header(1);
sample_rate = data_header(2);
window_overlap = data_header(3);

switch feature
    case 1
        result = internalBandMap(data,name,sample_rate,window_overlap);
        file_handle = 'band';
    case 2
    case 3
end

% write result back out for later
new_dir = [path '/' file_handle '/' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
mkdir(new_dir);
output_file = [new_dir '/' name '.mat'];
save(output_file,'result');

end