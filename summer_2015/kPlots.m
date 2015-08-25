function kPlots(features,groups)
close all;

if( groups < 8 )

colors1 = {'bo','ro','go','ko','mo','yo','co'};
colors2 = {'bx','rx','gx','kx','mx','yx','cx'};

[kMeans_index,kMeans_centroids] = kmeans(features,groups);

figure('name','kMeans Plot','numbertitle','off');
hold on;
for i=1:groups
    plot(features(kMeans_index==i,1),features(kMeans_index==i,2),colors1{i});
    plot(kMeans_centroids(i,1),kMeans_centroids(i,2),colors2{i},'MarkerSize',25,'linewidth',3);
end

else
    disp('Too many groups.');
end

end