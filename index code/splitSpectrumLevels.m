% take the FFT of the data. separate it into the standard energy bands of
% the brain: alpha(8-15), beta(16-31), delta(<4), gamma(32+), theta(4-7)
function result = splitSpectrumLevels(data,sample_rate)
[samples,window,channels] = size(data);
NFFT = 2^nextpow2(sample_rate);
NFFT_len = NFFT/2+1;
data_fft = fft(data,NFFT,2)/sample_rate;
data_freq = sample_rate/2*linspace(0,1,NFFT_len);
data_norm = 2*abs(data_fft(:,1:NFFT_len,:));

% section data into bands
band_data = bandBasedData(data_norm,data_freq);

match_index = zeros(samples,samples);
match_weights = [1 1 1 1 1];
for r=1:samples
    for i=r:samples
        match_index(r,i) = sum(([band_data(r,:)-band_data(i,:)]==0).*match_weights)/5;
    end
end
    

end