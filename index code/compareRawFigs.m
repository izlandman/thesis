file_name = '.\2015_10_15_10_11_26\warp\S001R03_20_.mat';
window_1 = 94;
window_2 = 393;
range = 2;

result_1 = rebuildRaw(file_name,window_1,range);
result_2 = rebuildRaw(file_name,window_2,range);

time = [1:length(result_1)];

figure(42);hold on;
plot(time,result_1,'Color',[0,0,0],'linewidth',2);
plot(time,result_2,'Color',[0,153/255,153/255],'linewidth',2);
xlim([1 max(time)]);
ylabel('Amplitude (\muV)');
xlabel('Time (seconds)');
title('Raw Event Signal Data');
ax = gca;
ax.FontSize = 20;
ax.XTick = 0:40:max(time);
legend('Event 2', 'Event 6','Location','south','Orientation','horizontal');
grid on;