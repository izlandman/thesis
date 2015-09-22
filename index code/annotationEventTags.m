function [events, anno_listing] = annotationEventTags(file_name,samples,sample_rate,window_overlap)

anno_listing = zeros(samples,1);

anno_data = dlmread(file_name);
anno_data_samples = round( anno_data(:,1:2)/(sample_rate*(100-window_overlap)/100) )+1;
anno_data_samples(end,2) = samples;
anno_index = arrayfun(@colon, anno_data_samples(:,1), anno_data_samples(:,2),'UniformOutput',0);

% make annotation index equal in length to processed file
for i=1:length(anno_data_samples(:,1))
    anno_listing(anno_index{i}) = anno_data(i,3);
end

events = [3 5 7];

% scale annotations to prime numbers
anno_listing(anno_listing==0) = 3;
anno_listing(anno_listing==1) = 5;
anno_listing(anno_listing==2) = 7;

end