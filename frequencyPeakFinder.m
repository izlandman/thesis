% yeah, pretty sure this isn't called by any of the final forms of the
% analysis functions. a reminant from the start of 2015 that was quickly
% discarded.

function peaks = frequencyPeakFinder(input)

iterations = length(input.fft);
peaks = zeros(64,5,6,iterations);

for i=1:iterations
    data_set = frequencyBands(input,i);
    for k=1:6
        peaks(:,:,k,i) = [cell2mat(struct2cell(data_set(k))'),(1:64)'];
    end
end


end

function [data_band] = frequencyBands(input,i)
    index_delta = (input.freq{i}<=4)==(input.freq{i}>=0.5);
    index_theta = (input.freq{i}>4)==(input.freq{i}<=8);
    index_alpha = (input.freq{i}>8)==(input.freq{i}<=16);
    index_mu = (input.freq{i}>=8)==(input.freq{i}<=12);
    index_beta = (input.freq{i}>16)==(input.freq{i}<=32);
    index_gamma = (input.freq{i}>32)==(input.freq{i}<=80);
    
    [delta.max_freq,delta.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_delta);
    [delta.min_freq,delta.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_delta);
    
    [theta.max_freq,theta.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_theta);
    [theta.min_freq,theta.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_theta);
    
    [alpha.max_freq,alpha.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_alpha);
    [alpha.min_freq,alpha.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_alpha);
    
    [mu.max_freq,mu.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_mu);
    [mu.min_freq,mu.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_mu);
    
    [beta.max_freq,beta.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_beta);
    [beta.min_freq,beta.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_beta);
    
    [gamma.max_freq,gamma.max_mag] = findMaxFreqs(input.fft{i},input.freq{i},index_gamma);
    [gamma.min_freq,gamma.min_mag] = findMinFreqs(input.fft{i},input.freq{i},index_gamma);
    
    data_band = [delta,theta,alpha,mu,beta,gamma];

end

function [max_freqs,value] = findMaxFreqs(data,frequency,band)
[value,index] = max(data(:,band),[],2);
max_freqs = frequency(band)';
max_freqs = max_freqs(index);
end

function [min_freqs,value] = findMinFreqs(data,frequency,band)
[value,index] = min(data(:,band),[],2);
min_freqs = frequency(band)';
min_freqs = min_freqs(index);
end