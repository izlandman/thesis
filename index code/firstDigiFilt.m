function result = firstDigiFilt(data,window_size,gain)

a = gain;
b = (1/window_size)*ones(1,window_size);
result = filter(b,a,data);

end