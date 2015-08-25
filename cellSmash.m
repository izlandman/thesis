% this was used to break down 4D into 3D for data processing, but turned
% out to not be necessary once I thought about how to actually handle the
% data.

function [output,r] = cellSmash(input)

iterations = length(input(1,1,1,:));
bands = length(input(1,1,:,1));
channels = length(input(:,1,1,1));
elements = length(input(1,:,1,1));

output = zeros(channels*iterations,elements,bands);
r = [];
for i=1:bands
    f = [];
    for k=1:iterations
        f = [f;input(:,:,i,k)];
    end
    output(:,:,i) = f;
    r = [r;f];
end

end