function acorPlot(signal1,signal2,fs)

[acor,lag] = xcorr(signal1,signal2);
[~,I] = max(abs(acor));
lagDiff = lag(I)
timeDiff = lagDiff/fs

figure(42);plot(lag,acor);
end