% perform fourier analysis to find dominant signal band peak values. this
% function is typically called by other functions when builiding the models
% from the raw edf data.

% INPUTS: DATA_INPUT should be channels verus time of the signal.
% SAMPLE_FREQUENCY should be the sampling frequency of the data.
% WINDOW_DURATION indicates the number of seconds the window should cover.
% FRAME_DURATION indicates the number of seconds the frame should cover.
% The overlap is 50% for the window as well.

% OUTPUTS: DATA_VECTOR is a two column cell of the frequencies and
% assocaited values of the transform for the given channel.

function data_vector = featureFinderSlim(data_input,sample_frequency,...
    window_duration,frame_duration)

[channels, duration ] = size(data_input);

window_size = window_duration*sample_frequency;
frame_size = frame_duration*sample_frequency;
NFFT = 2^nextpow2(window_size);
fft_end = NFFT/2+1;
fft_sample = zeros(channels,window_size);

% channels are a feature! add them!
data_vector.fft = cell(1,round(duration/(frame_size/2)));

frequency = sample_frequency/2*linspace(0,1,fft_end);

i = 0;
k = 1;
while ( i <= duration )
    fft_sample = zeros(channels,window_size);
    % handle variable window sizes
    window_start = i - round(window_size/2);
    window_end = window_start + window_size;
    if ( window_start < 1 )
        window_start = 1; 
    end
    if ( window_end > duration )
        window_end = duration;
    end
    
    % shift window for next iteration
    i = round(frame_size/2) + i;
    % populate data to be FFT'd
    sample_end = window_end-window_start+1;
    fft_sample(:,1:sample_end) = data_input(:,window_start:window_end);
    data_fft = fft(fft_sample,NFFT,2)/window_size;
    data_normalized = 2*abs(data_fft(:,1:fft_end));

    data_vector.fft{k} = data_normalized;
    data_vector.freq{k} = frequency;
    k = k + 1;
end

end