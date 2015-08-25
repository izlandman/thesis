% perform fourier analysis to find dominant signal band

% initial tool to find FEATURES in the signals. notice that it does this
% across all the channels so it only needs to iterate through time.
% presents with a sub-function that sorts the results into band specific
% data. the returned data_vector is a structure, which was not a wise
% decision given how they are dealt with and my goals for the data.

function data_vector = featureFinder(data_input,sample_frequency,...
    window_duration,frame_duration)

channels = length(data_input(:,1));
duration = length(data_input(1,:));

window_size = window_duration*sample_frequency;
frame_size = frame_duration*sample_frequency;
NFFT = 2^nextpow2(window_size);
fft_sample = zeros(channels,window_size);
% channels are a feature! add them!
data_vector.fft = cell(1,round(duration/(frame_size/2)));
data_vector.bands = cell(1,round(duration/(frame_size/2)));

i = 0;
while ( i <= duration )
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
    fft_sample(:,1:(window_end-window_start+1)) = data_input(:,window_start:window_end);
    data_fft = fft(fft_sample,NFFT,2)/window_size;
    frequency = sample_frequency/2*linspace(0,1,NFFT/2+1);
    data_normalized = 2*abs(data_fft(:,1:NFFT/2+1));
    % bin frequencies to find most active/strongest
    % data_band = frequencyBands(data_normalized,frequency);
    % match index to frequency, flatten matrix out to assign all variables
    % to one observation!
    r = i/round(frame_size/2);
    data_vector.fft{r} = data_normalized;
    data_vector.bands{r} = frequencyBands(data_normalized,frequency);
end

end

function [data_band] = frequencyBands(data,frequency)
    index_delta = (frequency<=4)==(frequency>=0.5);
    index_theta = (frequency>=4)==(frequency<=8);
    index_alpha = (frequency>=8)==(frequency<=16);
    index_mu = (frequency>=8)==(frequency<=12);
    index_beta = (frequency>=16)==(frequency<32);
    index_gamma = (frequency>=32)==(frequency<=80);
    
    max_delta = max( data(:,index_delta),[],2);
    frequency_delta = mean( data(:,index_delta),2);
    max_theta = max( data(:,index_theta),[],2);
    frequency_theta = mean( data(:,index_theta),2);
    max_alpha = max( data(:,index_alpha),[],2);
    frequency_alpha = mean( data(:,index_alpha),2);
    max_mu = max( data(:,index_mu),[],2);
    frequency_mu = mean( data(:,index_mu),2);
    max_beta = max( data(:,index_beta),[],2);
    frequency_beta = mean( data(:,index_beta),2);
    max_gamma = max( data(:,index_gamma),[],2);
    frequency_gamma = mean( data(:,index_gamma),2);
    
    data_band = [frequency_delta,frequency_theta,frequency_alpha,...
        frequency_mu,frequency_beta,frequency_gamma,max_delta,max_theta,...
        max_alpha,max_mu,max_beta,max_gamma];

end