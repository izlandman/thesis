function rebuilt_raw = rebuildRaw(file_name,window,range)

% this should generate final_output a {2x1} cell
% final_output{1} -> [type, window_size, overlap%]
% final_output{1} -> data matrix [n x window_size]
load(file_name);

overlap = (100-final_output{1}(3))/100;
% given overlap, how many windows must be ignored to rebuild raw signal
window_step = 1/overlap;

if(range ~= 0)
    half_window = window_step * range;
    rebuilt_raw = zeros(1,2*range*final_output{1}(2));
    window_start = window - half_window;
    % i becomes the index of the raw data windows
    for i = 0:window_step:2*half_window-window_step
        indx = (i/window_step)*final_output{1}(2) + 1;
        rebuilt_raw(indx:indx-1+final_output{1}(2)) = ...
            final_output{2}(i*window_step + window_start,:);
    end
    window_index = window_start:window_step:window_start+2*half_window;
    xticks = (window_index - window_start)/window_step.*final_output{1}(2);
else
    % range is zero, find that specific window
    rebuilt_raw = final_output{2}(window,:);
    xticks = [1 final_output{1}(2)];
    window_index = [window-2 window+2];
end

% plot raw data

title_label = ['Window: ' num2str(window) ' Range: ' num2str(range)];
figure('numbertitle','off','name',['Raw Data: ' num2str(window)])
plot(rebuilt_raw,'LineWidth',2);
title(title_label,'fontsize',20);
grid on;
xlabel('Window Index')
ylabel('Amplitude (\muV)')
xlim([0 length(rebuilt_raw)]);
ax = gca;
ax.FontSize = 20;
ax.XTick = xticks;
ax.XTickLabel = num2cell(window_index);
end