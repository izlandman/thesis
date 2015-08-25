% present a portion of the data in the annotation window and chomp through
% the data as the subject annotates it whatever fashion they deem best.
% Present one window that shows a larger scale view to provide context and
% then a smaller focused view for accurate feature selection/annotation.

function dataAnnotation(data_file,sample_rate,window_duration)

close all;

data_raw = csvread(data_file);

window_count = window_duration * sample_rate;
data_length = length(data_raw);
iterations = round(data_length/window_count);

% setup annotation window

[coords] = annotationWindow(data_raw,window_count,sample_rate,data_length);

[good_distance, bad_distance] = annotationFeature(coords_g,coords_b,sample_rate);

end