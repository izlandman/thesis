% Could use this, but there are better built in functions and a better
% homemade function as well. Just wanted to remove some of the bells and
% whisltes from Matlab's version to attempt to cut down the memory usage on
% process and the eventual results.

function myPSD(x,Fs)

x_len = length(x(1,:));
N = 2^nextpow2(x_len);
freq = 0:Fs/x_len:Fs/2;

% my tool

xdft = fft(x,N,2);
xdft = xdft(:,1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(:,2:end-1) = 2*psdx(:,2:end-1);

figure(42);
plot(freq,10*log10(psdx(1,:)));
grid on;
title('Periodogram Using FFT');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

% built in tool

Pxx = abs(fft(x,N,2)).^2/x_len/Fs;
Hpsd = dspdata.psd(Pxx(1,1:x_len/2),'Fs',Fs);
figure(43);
plot(Hpsd);

end