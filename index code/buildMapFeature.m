% operate on the given data by calling the required feature tool to analyze
% the sample at the given sample rate
function result = buildMapFeature(data,sample_rate,window_overlap,feature)
[channels,duration] = size(data);
% break data down into windows with desired overlap
window_shift = 1 - window_overlap/100;
num_samples = duration / ( sample_rate * window_shift ) + 1;
sample_screen = zeros(num_samples,duration,channels);
for i=1:num_samples
    sample_count = (i-1) * window_shift * sample_rate + sample_rate/2;
    leading_edge = sample_count-sample_rate;
    if( sample_count < sample_rate )
        sample_window = [ones(1,sample_count)  zeros(1,duration-sample_count)];
    elseif( sample_count >= sample_rate && leading_edge <= duration-sample_rate )
        sample_window = [zeros(1,leading_edge) ones(1,sample_rate) zeros(1,duration-sample_rate-leading_edge)];
    else
        sample_window = [zeros(1,leading_edge) ones(1,duration-leading_edge)];
    end
    sample_screen(i,:,:) = sample_window;
end
end