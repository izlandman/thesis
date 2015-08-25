% this should be used to plot a full compliment of results from quadrant
% compares. attempting to plot using only one or two quadrants produces
% poor plots. this is mostly cosmetic as the data generated comes from
% _epochConfusionMatrix_ and not this function.

% INPUTS: Paramaters pertaining to the epoch and gmm folder locations in
% sttring format '', along with integer vectors aligned within the options
% available for bands and quadrants. verbose save is not advised as it
% grealty increases operation time.

% OUTPUTS: plots showing overall results across bands/channels. it can
% save, see the commented out lines, but the version of matlab I use appear
% to have unique commands for this feature.

function quadrantCompare(epochs,gmms,bands,quadrants,verbose_save)

band_names = {'delta','theta','alpha','mu','beta','gamma'};
quadrant_names = {'none','front right','front left','back left','back right','medial line','coronal line'};

num_quadrants = length(quadrants);
num_bands = length(bands);

resultant_accuracy_euc = zeros(num_quadrants,num_bands);
resultant_accuracy_mah = zeros(num_quadrants,num_bands);

for q=1:num_quadrants
    for b=1:num_bands
        disp(['Loop iteration ',num2str((q-1)*num_bands+b),' of ',num2str(num_quadrants*num_bands)]);
        if( verbose_save == 0 )
            [resultant_accuracy_euc(q,b),resultant_accuracy_mah(q,b)] =  epochConfusionMatrix(epochs,gmms,bands(b),quadrants(q));
        else
            [resultant_accuracy_euc(q,b),resultant_accuracy_mah(q,b)] =  epochConfusionMatrix(epochs,gmms,bands(b),quadrants(q),1);
        end
        
    end
end

figure('name','Quadrant Compare, Euclidean','NumberTitle','off');
acc_plot(resultant_accuracy_euc,quadrants,num_quadrants,bands,quadrant_names,band_names);
% savefig('quadrant compare Euc.fig');
figure('name','Quadrant Compare, Mahalanobis','NumberTitle','off');
acc_plot(resultant_accuracy_mah,quadrants,num_quadrants,bands,quadrant_names,band_names);
% savefig('quadrant compare Mah.fig');

% save mat file
result_acc_euc = resultant_accuracy_euc;
data_save = 'quadrant_removal_data_euc.mat';
save(data_save,'result_acc_euc');
result_acc_mah = resultant_accuracy_mah;
data_save = 'quadrant_removal_data_mah.mat';
save(data_save,'result_acc_mah');
end

function acc_plot(data,quadrants,num_quadrants,bands,quadrant_names,band_names)
subplot(211);plot(data,'LineWidth',2); grid on;
legend(band_names{bands},'location','bestoutside');
Xt = 1:num_quadrants;
X1 = [1 num_quadrants];
set(gca,'XTick',Xt,'Xlim',X1);
set(gca,'XTickLabel',quadrant_names(quadrants));
title(' Quadrant Removal Accuarcy ');
ylabel('Accuracy'); xlabel('Quadrant Location');

subplot(212);plot(data(2:end,:)./repmat(data(1,:),length(quadrants)-1,1),'LineWidth',2);
grid on; legend(band_names{bands},'location','bestoutside');
Xt = 1:num_quadrants-1;
X1 = [0 num_quadrants-1];
set(gca,'XTick',Xt,'Xlim',X1);
set(gca,'XTickLabel',quadrant_names(quadrants(2:end)));
title(' Quadrant Removal Accuarcy ');
ylabel('Relative Accuracy to Full Channel Set'); xlabel('Quadrant Location');

end