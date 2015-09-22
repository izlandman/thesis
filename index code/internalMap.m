function internalMap(file_name)

data = load(file_name);
data_header = data.final_output{1};
data = data.final_output{2};
[path,name,ext] = fileparts(file_name);
feature = data_header(1);
sample_rate = data_header(2);
window_overlap = data_header(3);
[~,~,channels] = size(data);

result = cell(channels,1);

for k=1:channels

switch feature
    case 1
        result{k} = internalBandMap(data(:,:,k),name,sample_rate,window_overlap);
        file_handle = 'band';
    case 2
        result{k} = internalWarpMap(data(:,:,k),name,sample_rate,window_overlap);
        file_handle = 'warp';
    case 3
end

end

% write result back out for later
new_dir = [path '/' file_handle '_results/' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
% if parent folders do not exist, Matlab will make them. otherwise it uses
% already produced folders
mkdir(new_dir);
output_file = [new_dir '/' name '.mat'];
save(output_file,'result');

end