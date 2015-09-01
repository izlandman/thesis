% operate on the given data by calling the required feature tool to analyze
% the sample at the given sample rate
function result = buildMapFeature(data,sample_rate,window_overlap,feature)
% result is a cell of length feature. this allows it to hold arrays of
% length num_samples, but then each feature will produce variable length
% symbols to be computed
result = cell(size(feature));
[channels,duration] = size(data);
window_size = sample_rate;
% break data down into windows with desired overlap
window_shift = 1 - window_overlap/100;
num_samples = duration / ( window_size * window_shift ) + 1;
sample_screen = zeros(num_samples,window_size,channels);

% build an array of just the data samples to be passed, this should allow
% matlab to keep up for processing the initial features. this saves me time
% from having to deploy feature building functions in C/C++. of course, the
% mapping will most likely need to be done in C/C++ given the high
% dimensionality of the data being configured.
for i=1:num_samples
    sample_count = (i-1) * window_shift * window_size + window_size/2;
    leading_edge = sample_count-window_size;
    if( sample_count < window_size )
        sample_screen(i,:,:) = [data(:,1:sample_count)  zeros(channels,window_size-sample_count)]';
    elseif( sample_count >= window_size && leading_edge <= duration-window_size )
        sample_screen(i,:,:) = data(:,leading_edge+1:leading_edge+sample_rate)';
    else
        sample_screen(i,:,:) = [zeros(channels,window_size-(duration-leading_edge+1)) data(:,leading_edge:end)]';
    end
end

% given the feature or features to build, loop through all the feature
% building tools

for i=1:length(feature)
    % use a switch because it'll probably scale the easiest, start with
    % case 1 being FFT into specific bands
    switch feature(i)
        case 1
            result{i} = splitSpectrumLevels(sample_screen,sample_rate);
        case 2
        case 3
        case 4
    end
end

end