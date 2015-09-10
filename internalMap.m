function internalMap(file_name)

data = dlmread(file_name);
data_header = data(1,:);
data = data(2:end,:);
[path,name,ext] = fileparts(file_name);
feature = data_header(1);
sample_rate = data_header(2);
window_overlap = data_header(3);

switch feature
    case 1
        result = internalBandMap(data,name,sample_rate,window_overlap);
    case 2
    case 3
end



end