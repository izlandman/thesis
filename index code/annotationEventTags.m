function [events, anno_listing, event_length] = annotationEventTags(file_name,samples,sample_rate,window_overlap)

anno_listing = zeros(samples,1);
% window overlap starts at 50%, so first two samples are part of first
% event. any excess samples after that are part of final event
anno_data = dlmread(file_name);

events = anno_data(:,3);
anno_data_samples = round( anno_data(:,1:2)/(sample_rate*(100-window_overlap)/100) );
anno_data_samples(1,1) = -2;
anno_data_samples = anno_data_samples + 2;
anno_data_samples(:,1) = anno_data_samples(:,1) + 1;
anno_data_samples(end,2) = samples;

anno_index = arrayfun(@colon, anno_data_samples(:,1), anno_data_samples(:,2),'UniformOutput',0);

% make annotation index equal in length to processed file
event_length = zeros(1,length(anno_data_samples(:,1)));
for i=1:length(anno_data_samples(:,1))
    anno_listing(anno_index{i}) = anno_data(i,3);
    event_length(i) = anno_data_samples(i,2) - anno_data_samples(i,1) + 1;
end

event_double = [event_length(events==0) event_length(events==1) event_length(events==2)];
event_length = event_double;

% scale annotations to prime numbers
anno_listing(anno_listing==0) = 3;
anno_listing(anno_listing==1) = 5;
anno_listing(anno_listing==2) = 7;
events(events==0) = 3;
events(events==1) = 5;
events(events==2) = 7;

end