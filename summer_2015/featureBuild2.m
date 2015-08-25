% assume data is already filtered and the selection being passed in has
% been singled out via annotation for use as a feature. plot the time
% series, psd, and fft.. along with any other desired analysis that may be
% useful in discerning the underlying cause for annotation

% the majority of this should really be functions tied to the feature class
% that get called only when needed to reduce data storage. just save the
% selected feature and generate functions to return whatever data is
% required given the needs of analysis

function result = featureBuild2(data,sample_frequency,start_time,stop_time,button)

result = FeatureCrate;
no_toolbox = 1;

result.source = data;
result.start = start_time;
result.stop = stop_time;
result.duration = stop_time-start_time;
plot_fft = [];
fp = [];
plot_pxx = [];
power_bands = [];
% write this in later as a function of the object!
if( button == 1 )
    result.type = 'g';
elseif( button == 3 )
    result.type = 'b';
else
    result.type = num2str(button);
end

L = length(data(:,1));
NFFT = 2^nextpow2(L);
% x_time = linspace(0,L/sample_frequency,L);

% not sure about removing any bias present in the original time signal, but
% ideally doing least squares should help 'find' what the clinician sees in
% the data

% time_bias = mean(data);
% plot_data = data - repmat(time_bias,L,1);

plot_data = data;
% build feature with common time duration
time_set_data = plot_data;

if( no_toolbox == 0 )

[pxx,fp] = pwelch(plot_data,[],[],NFFT,sample_frequency);
plot_pxx = 20*log10(pxx);
% this should be passed far more variables to determine power bands for
% unique data sets.
power_bands = powerBand(plot_pxx,fp,10,2.5,15,3,20,8,30,5);

data_fft = fft(plot_data,NFFT)/L;
plot_fft = 2*abs(data_fft(1:NFFT/2+1,:));
% F = sample_frequency/2*linspace(0,1,NFFT/2+1);
end
% normalize the data around y-axis, as the amplitude should not be the
% feature so much as the relationship between the amplitudes

% if( nargin == 3 )
%     close all;
%     figure('name','Feature Plot','NumberTitle','off');
%     subplot(311);plot(x_time,plot_data);
%     title('Time Series Data');xlabel('Time (seconds)');ylabel('Raw Amplitude (volts)');
%     subplot(312);plot(F,plot_fft);
%     title('Fourier Transform Data');xlabel('Frequency (hertz)');ylabel('Amplitude');
%     subplot(313);plot(fp,plot_pxx);
%     title('Power Spectral Density Data');xlabel('Frequency (hertz)');ylabel('Magnitude (dB)');
% end

result.features = {plot_data,plot_fft,time_set_data,plot_pxx,power_bands};
result.frequency = fp;

end

% take data from PSD and pull out specific values for given power bands.
% varargin allows for pairs of center frequency and bandwidth to be passed
% in to build however many power bands are needed
function result = powerBand(pxx,fp,varargin)

sensors = length(pxx(1,:));
pair_count = length(varargin);
power_band_count = pair_count / 2;
result = zeros(power_band_count,sensors);

for i=1:power_band_count
    band_low = varargin{i*2-1}-varargin{i*2};
    band_high = varargin{i*2-1}+varargin{i*2};
    freq_index = (fp < band_high) & (fp > band_low);
    result(i,:) = mean( pxx(freq_index,:) );
end

end