% read file and filter file, return only data linked to annotations, the
% channels can be randomized by rndm is any value aside from 0. this was a
% thought, but randomizing the channels makes everything fall apart pretty
% quickly when building models.

% INPUTS: a FILE_NAME is passed in as a string along with the structure
% FLTR

% OUTPUTS: CLASS_LABELED and CLASS_DURATION return vectors associated with
% the annotations from the PHYSIONET imagined motion data set.
% DATA_FILTERED is the raw data after filtering and SAMPLE_RATE finds the
% sample rate of the data, while EVENTS_DURATION lists the duration of each
% annotated section
function [class_labeled, class_duration, data_filtered, sample_rate,...
    events_duration] = filePrep(file_name, fltr, rndm)
if( nargin == 2)
    rndm = 0;
end
% use edfread from Matlab Online Repository
[data,header] = lab_read_edf(file_name);
% randomize channel
if( rndm ~= 0 )
    data = data(randperm(header.numchannels),:);
end
sample_rate = max(header.samplingrate);
[B,A] = butter(fltr.butter_order,[fltr.butter_low fltr.butter_high]/(sample_rate/2));
data_filtered = filter(B,A,data);

% cull data to only include annotated data, [ T0 T1 T2 ]
events = length( header.events.TYP );
[path,name,ext] = fileparts(file_name);
task = str2double( name(end-1:end) );
class_labeled = zeros(1,events);
class_duration = zeros(2,events);
% time index starts with 0, Matlab starts with 1!
events_start = header.events.POS + 1;
events_stop = header.events.DUR + events_start - 1;
events_duration = sum(header.events.DUR);
event_class = header.events.TYP;

% parse valid data
for i=1:events
    class_duration(:,i) = [events_start(i); events_stop(i)];
end

% parse valid labels

annotation_rest = strcmp(event_class,'T0');
class_labeled(annotation_rest) = 1;
if( 0 < sum( task == [ 3 4 7 8 11 12 ] ) )
    annotation_left_fist = strcmp(event_class,'T1');
    annotation_right_fist = strcmp(event_class,'T2');
    class_labeled(annotation_left_fist) = 2;
    class_labeled(annotation_right_fist) = 3;
elseif( 0 < sum( task == [ 5 6 9 10 13 14 ] ) )
    annotation_both_fist = strcmp(event_class,'T1');
    annotation_both_feet = strcmp(event_class,'T2');
    class_labeled(annotation_both_fist) = 4;
    class_labeled(annotation_both_feet) = 5;
end



end