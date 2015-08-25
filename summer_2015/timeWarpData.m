% Randomly (gaussian) increase or decrease the feature in time and adjust
% the annotation marker accordingly
function [new_data,new_time] = timeWarpData(raw_data,raw_time)

% decimate or downsample or upsample or resample?
top_rand = randi(6,1)+4;
bot_rand = randi(6,1)+4;

new_data = resample(raw_data,top_rand,bot_rand);

new_time = round(raw_time*top_rand/bot_rand);
end