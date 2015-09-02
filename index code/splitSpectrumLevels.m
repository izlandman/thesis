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

match_index = zeros(samples,samples,channels);
match_weights = [1 1 1 1 1];
for q=1:channels
    for r=1:samples
        for i=r:samples
            match_index(r,i,q) = sum(([band_data(r,:,q)-band_data(i,:,q)]==0).*match_weights)/5;
        end
    end
end

% group matching samples together by index
count = 0;
grouping = [];
index = (1:samples);
while count < samples
    [y,r] = find( match_index(index(1),:)==1 );
    % remove index if matched
    A = ismember(index,r);
    index(A) = [];
    count = count + sum(y);
    grouping{end+1} = r; 
end
end