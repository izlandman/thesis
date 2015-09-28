function exampleAnnotationPlot(file_name,location)
close all;
num_samples = 501;
sample_rate = 160;
window_overlap = 75;

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix

if( location == 1 )
    % at temple
    anno_name = ['C:/_ward/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
else
    % not at temple, at home?
    anno_name = ['F:/_research/_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
end

[event_tags, anno_listing] = annotationEventTags(anno_name,num_samples,sample_rate,window_overlap);
%annotation plot
real_events = anno_listing;
% set rest to 0, event 1 to 1 and event 2 to 2
real_events(real_events == 3) = 0;
real_events(real_events == 5) = 1;
real_events(real_events == 7) = 2;
% get them back in time domain, from sample domain
time_index = (1/160)*[0:num_samples-1]*(100-window_overlap)/100*sample_rate;
figure('numbertitle','off','name','Annotation Record Plot');
plot(time_index,real_events,'linewidth',2);
ylim([min(real_events)-0.1 max(real_events)]+0.1);xlim([0 max(time_index)]);
ylabel(' Event Marker ','fontsize',12);
xlabel(' Time (seconds) ','fontsize',12);
title('Annotation Record','fontweight','bold','fontsize',14);
end