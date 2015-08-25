close all;

% filter! 0.5hz to 80hz given sample rate is 200
[b,a] = butter(7,[0.5/100 80/100]);

filtered_data = filter(b,a,data_T2L347(:,1));

plot(filtered_data);
length(data_T2L347(:,1));

[x,y] = ginput(2);

digits(min(x));
start = digits;

digits(max(x));
stop = digits;

new_data = [data_T2L347(1:start,1)',zeros(stop-start-1,1)',data_T2L347(stop:end,1)'];
plot(new_data);
data_length = length(new_data);

num_windows = 9;
win_start = 1;
window_size = round( data_length/num_windows );
r = 1;



while win_start<data_length
    
    win_end = win_start+window_size-1;
    figure(r+10);
    if( win_end <= data_length)
        [pxx,f] = pwelch(new_data(win_start:win_end),[],[],[],200);
        subplot(211);plot(new_data(win_start:win_end));
        subplot(212);plot(f,20*log10(pxx));
    elseif( win_end > data_length)
        [pxx,f] = pwelch(new_data(win_start:end),[],[],[],200);
        subplot(211);plot(new_data(win_start:end));
        subplot(212);plot(f,20*log10(pxx));
    end
    r = r + 1;
    win_start = win_end + 1;
end