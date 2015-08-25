% SUPER IMPORTANT

% As the ordering of files and folders can be unique to an
% OS/Matlab(software) this ensures that things are sorted numerically
% within Matlab correctly to keep models of epochs and gmms indexed
% uniformly

function order_list = numericFileList(directory,file_start)
list = dir(fullfile(directory,'*.mat'));
name = {list.name};
str = sprintf('%s#',name{:});
num = sscanf(str,strcat(file_start,'%d.mat#'));
[dummy,index] = sort(num);
order_list = name(index);
end