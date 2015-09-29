function [events, anno_listing, event_length] = annotationEventTags(file_name,samples,sample_rate,window_overlap)

anno_listing = zeros(samples,1);

anno_data = dlmread(file_name);
anno_data_samples = round( anno_data(:,1:2)/(sample_rate*(100-window_overlap)/100) )+1;
anno_data_samples(end,2) = samples;
anno_index = arrayfun(@colon, anno_data_samples(:,1), anno_data_samples(:,2),'UniformOutput',0);

% make annotation index equal in length to processed file
event_length = zeros(1,length(anno_data_samples(:,1)));
for i=1:length(anno_data_samples(:,1))
    anno_listing(anno_index{i}) = anno_data(i,3);
    event_length(i) = anno_data_samples(i,2) - anno_data_samples(i,1);
end

event_double = [event_length(anno_data(:,3)==0) event_length(anno_data(:,3)==1) event_length(anno_data(:,3)==2)];
event_length = event_double;
events = [3 5 7];

% scale annotations to prime numbers
anno_listing(anno_listing==0) = 3;
anno_listing(anno_listing==1) = 5;
anno_listing(anno_listing==2) = 7;

end