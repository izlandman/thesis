% when run this complies all data stored in results folders pertaining to
% confusion matrix to build one overall figure

% This can only be run on the main data folder assuming there is a sub
% folder titled 'figures'. The output are plots aggregating all of the
% results of the epochConfusionMatrix results stored within 'figures'.

function epochConfResults
close all;

% will find folders labeled with 'figure' where data is stored
list = dir;

k = 1;
for i=1:length(list)
    if( findstr(list(i).name,'figures') ~= 0 )
        data_folders{k} = list(i).name;
        k = k + 1;
    end
end

[euclidean_data, mahalanobis_data] = matrixBuild(data_folders); 

true_mahal = mean(mahalanobis_data,3);
true_euclidean = mean(euclidean_data,3);

% plot!
band_names = {'delta','theta','alpha','mu','beta','gamma'};
quadrant_names = {'Baseline','Right Anterior','Left Anterior','Left Posterior','Right Posterior','Medial Line','Coronal Line'};

figure('name','All Trial Euclidean Accuracy','NumberTitle','off');
acc_plot(true_euclidean,[1:7],7,[1:6],quadrant_names,band_names);
figure('name','All Trial Mahalanobis Accuracy','NumberTitle','off');
acc_plot(true_mahal,[1:7],7,[1:6],quadrant_names,band_names);

% overall accuracy assuming 50% or more agree
for i=1:length(true_euclidean(:,1))
    euclidean_accuracy(i) = quadrantAccuracry(true_euclidean(i,1:6));
    mahalanobis_accuracy(i) = quadrantAccuracry(true_mahal(i,1:6));
end

figure('name','majority rules accuracy','numbertitle','off');
plot([euclidean_accuracy;mahalanobis_accuracy]','linewidth',2);grid on;
set(gca,'FontSize',12);
legend({'Euclidean','Mahalanobis'},'location','southoutside','orientation','horizontal');
Xt = 1:1:7;
X1 = [1 7];
set(gca,'XTick',Xt,'Xlim',X1);
set(gca,'XTickLabel',quadrant_names([1:7]));
title(' Euclidean versus Mahalanobis Accuarcy ');
ylabel('Accuracy'); xlabel('Quadrant Location');

euclidean_accuracy
mahalanobis_accuracy

end

function accuracy = quadrantAccuracry(input_acc)
input_error = 1 - input_acc;

samples = length(input_acc);
other = (1:samples);

accuracy = 0;

for i=0:round(samples/2)-1
    combos = combntns(1:samples,samples-i);
    for r=1:length(combos(:,1))
        error = setdiff(other,combos(r,:));
        accuracy = accuracy + prod([input_acc(combos(r,:)),input_error(error)]);
    end
end
end

function [euc_mat, mah_mat] = matrixBuild(folders)
num_sets = length(folders);

for r=1:num_sets
    euc_mat(:,:,r) = importdata( [folders{r},'/quadrant_removal_data_euc.mat'] );
    mah_mat(:,:,r) = importdata( [folders{r},'/quadrant_removal_data_mah.mat'] );
end


end

function acc_plot(data,quadrants,num_quadrants,bands,quadrant_names,band_names)
subplot(211);plot(data,'LineWidth',2); grid on;
set(gca,'FontSize',12);
legend(band_names{bands},'location','bestoutside');
Xt = 1:1:num_quadrants;
X1 = [1 num_quadrants];
set(gca,'XTick',Xt,'Xlim',X1);
set(gca,'XTickLabel',quadrant_names(quadrants));
title(' Quadrant Removal Accuarcy ');
ylabel('Accuracy'); xlabel('Quadrant Location');

subplot(212);plot(data(2:end,:)./repmat(data(1,:),length(quadrants)-1,1),'LineWidth',2);
grid on; set(gca,'FontSize',12);
legend(band_names{bands},'location','bestoutside');
Xt = 1:1:num_quadrants-1;
X1 = [1 num_quadrants-1];
set(gca,'XTick',Xt,'Xlim',X1);
set(gca,'XTickLabel',quadrant_names(quadrants(2:end)));
title(' Quadrant Removal Accuarcy ');
ylabel('Relative Accuracy to Baseline'); xlabel('Quadrant Location');
end