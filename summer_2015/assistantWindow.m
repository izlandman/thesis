% generate helper window and update base plot
function assistantWindow(raw_data,window_start,window_end,sample_rate,...
    window_count,new_data,h,calc_h)

yY = raw_data(window_start:window_end,:);
xX = linspace(window_start/sample_rate,window_end/sample_rate,window_count);

guess_y = new_data;

% update the plot window!

for i=1:length(h)
    set(h(i),'XData',xX,'YData',yY(:,i));grid on;
    set(calc_h(i),'XData',xX,'YData',guess_y(:,i));grid on;
end

end