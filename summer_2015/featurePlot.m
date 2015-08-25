% assume data is already filtered and the selection being passed in has
% been singled out via annotation for use as a feature. plot the time
% series, psd, and fft.. along with any other desired analysis that may be
% useful in discerning the underlying cause for annotation

function featurePlot(data,sample_frequency)
close all;

L = length(data);
NFFT = 2^nextpow2(L);
x_time = linspace(0,L/sample_frequency,L);

[pxx,fp] = pwelch(data,[],[],NFFT,sample_frequency);

data_fft = fft(data,NFFT)/L;
F = sample_frequency/2*linspace(0,1,NFFT/2+1);

figure('name','Feature Plot','NumberTitle','off');
subplot(311);plot(x_time,data);
title('Time Series Data');xlabel('Time (seconds)');ylabel('Raw Amplitude (volts)');
subplot(312);plot(F,2*abs(data_fft(1:NFFT/2+1)));
title('Fourier Transform Data');xlabel('Frequency (hertz)');ylabel('Amplitude');
subplot(313);plot(fp,20*log10(pxx));
title('Power Spectral Density Data');xlabel('Frequency (hertz)');ylabel('Magnitude (dB)');

end