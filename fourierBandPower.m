% And this was started but never completed, so ignore it.

function [band_power] = fourierBandPower(signal, window_duration,...
    frame_duration, sample_rate)

% convert window_duration in time to window of duration samples
window = window_duration * sample_rate;
frame = frame_duration * sample_rate;
% work out how many unique FFTs must be carried out
iterations = length(signal(1,:))/frame;
NFFT = 2^nextpow2(window);

for i=1:interations
    data_fft = buildFFTdata(signal,window,frame,i);
end

end

function [output_data] = buildFFTdata(signal,window,frame,index)
output_data = zeros(length(signal(:,1)),window);
index_left = index + round( (index-1)*frame/2 ) - round(window/2) + 1;
index_right = index_left + round(window/2);

% catch edge conditions
if( index_left < 0 )
    index_left = 1;
elseif( index_right > length(signal(1,:)) )
    index_right = length(signal(1,:));
end
end