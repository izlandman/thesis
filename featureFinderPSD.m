% perform fourier analysis to find dominant signal band

% another attempt at my own PSD, probably better to NOT USE THIS ONE. and
% instead use the other that has lines of code and is streamlined.

function [psd_split,psd_full,psd_band,frequency] = featureFinderPSD(data_input,sample_frequency,...
    window_duration,frame_duration)

channels = length(data_input(:,1));
duration = length(data_input(1,:));
num_bands = 6;

window_size = window_duration*sample_frequency;
frame_size = frame_duration*sample_frequency;
NFFT = 2^nextpow2(window_size);
fft_sample = zeros(channels,window_size);
% channels are a feature! add them!
psd_band = cell(round(duration/(frame_size/2)),num_bands);
psd_split = cell(round(duration/(frame_size/2)),1);
psd_full_0 = zeros(round(duration/(frame_size/2)),NFFT/2+1);

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
    % take the fft
    data_fft = fft(fft_sample,NFFT,2);
    frequency = sample_frequency/2*linspace(0,1,NFFT/2+1);
    % build power vector
    pXX = abs(data_fft).^2 / (window_end-window_start+1) / sample_frequency ;
    
    % group by frequency band and average together for PSD
    grouped_data = frequencyBands(pXX,frequency);
    
    r = i/round(frame_size/2);
    
    for k=1:num_bands
        psd_band{r,k} = dspdata.psd(grouped_data{k,2},grouped_data{k,1},'Fs',sample_frequency);
    end
    
    psd_split{r} = dspdata.psd(pXX(:,1:length(pXX)/2+1),'Fs',sample_frequency);
    
    psd_full_0(r,:) = mean(pXX(:,1:length(pXX)/2+1));
    
end

psd_full = dspdata.psd(sum(psd_full_0),'Fs',sample_frequency);

end

function [data_outpt] = frequencyBands(data_input,frequency)
    data_outpt = cell(6,2);
    index_delta = (frequency<=4)==(frequency>=0.5);
    index_theta = (frequency>=4)==(frequency<=8);
    index_alpha = (frequency>=8)==(frequency<=16);
    index_mu = (frequency>=8)==(frequency<=12);
    index_beta = (frequency>=16)==(frequency<32);
    index_gamma = (frequency>=32)==(frequency<=80);
    
    % log frequency range
    data_outpt{1,1} = frequency(index_delta);
    data_outpt{2,1} = frequency(index_theta);
    data_outpt{3,1} = frequency(index_alpha);
    data_outpt{4,1} = frequency(index_mu);
    data_outpt{5,1} = frequency(index_beta);
    data_outpt{6,1} = frequency(index_gamma);
    
    data_outpt{1,2} = mean( data_input(:,index_delta));
    data_outpt{2,2} = mean( data_input(:,index_theta));
    data_outpt{3,2} = mean( data_input(:,index_alpha));
    data_outpt{4,2} = mean( data_input(:,index_mu));
    data_outpt{5,2} = mean( data_input(:,index_beta));
    data_outpt{6,2} = mean( data_input(:,index_gamma));
    
end