function result = bandBasedData(data,freq)
[samples,fft,channels] = size(data);
result = ones(samples,5,channels);
operational_data = cell(5,2);
band_means = zeros(samples,channels,5);

index_delta = (freq<=4)==(freq>=0.5);
index_theta = (freq>4)==(freq<=8);
index_alpha = (freq>8)==(freq<=16);
index_beta = (freq>16)==(freq<=32);
index_gamma = (freq>32)==(freq<=80);

operational_data{1,1} = data(:,index_alpha,:);
operational_data{2,1} = data(:,index_beta,:);
operational_data{3,1} = data(:,index_delta,:);
operational_data{4,1} = data(:,index_gamma,:);
operational_data{5,1} = data(:,index_theta,:);

for i = 1:5
    band_means(:,:,i) = mean(operational_data{i,1},2);
    operational_data{i,2} = [mean(band_means(:,:,i))' std(band_means(:,:,i))'];
end
% divide the energy into three tiers, one sigma below, between one sigma,
% and greather than one sigma
for i=1:5
    for k=1:-2:-1
        index_compare = repmat(squeeze(operational_data{i,2}(:,1,:) + ...
            k*operational_data{i,2}(:,2,:))',samples,1);
        index = squeeze(band_means(:,:,i)) < index_compare;
        for r=1:channels
            result( index(:,r),i ,r ) = result( index(:,r),i ,r ) + 1;
        end
    end
end

end