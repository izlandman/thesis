% THIS DOESN'T DO ANYTHING USEFUL, WHY DID YOU WRITE IT?

% return the distance of the given epoch (singular) to a given gmm
% (singular) over a specific set of bands (variable)

function [distances] = epochDistanceMeasure(epoch,gmm,bands)

num_bands = length(bands);
num_epochs = length(epoch(1,1,1,:));
feature = 2;
% gmm_mu = zeros(features,num_bands);
% gmm_sigma = zeros(features,features,num_bands);
% 
% % gmm rebuild model as desired
% for i=1:num_bands
%     gmm_mu(:,i) = gmm{bands(i)}.mu;
%     gmm_sigma(:,:,i) = gmm{bands(i)}.Sigma;
% end

[gmm_mu,gmm_sigma] = rebuildBands(gmm,bands,num_bands);

gmm_dat_mu = mean(gmm_mu,2);
gmm_dat_sigma = mean(gmm_sigma,3);

% epoch rebuild model as desired
epoch_dat = mean( squeeze( epoch(:,feature,bands, round( rand*(num_epochs-1)+1))),2);

distances(1) = pdist2(epoch_dat',gmm_dat_mu');
distances(2) = mahal( gmdistribution(gmm_dat_mu',gmm_dat_sigma), epoch_dat' );
end

function [gmm_mu,gmm_sigma] = rebuildBands(gmm,bands,num_bands)

% there has to be at least one
gmm_mu(:,1) = gmm{bands(1)}.mu;
gmm_sigma(:,:,1) = gmm{bands(1)}.Sigma;

if( num_bands > 1 )
    gmm_mu(:,2) = gmm{bands(2)}.mu;
    gmm_sigma(:,:,2) = gmm{bands(2)}.Sigma;
    
    switch num_bands
        case 3
            gmm_mu(:,3) = gmm{bands(3)}.mu;
            gmm_sigma(:,:,3) = gmm{bands(3)}.Sigma;
        case 4
            gmm_mu(:,3) = gmm{bands(3)}.mu;
            gmm_sigma(:,:,3) = gmm{bands(3)}.Sigma;
            gmm_mu(:,4) = gmm{bands(4)}.mu;
            gmm_sigma(:,:,4) = gmm{bands(4)}.Sigma;
        case 5
            gmm_mu(:,3) = gmm{bands(3)}.mu;
            gmm_sigma(:,:,3) = gmm{bands(3)}.Sigma;
            gmm_mu(:,4) = gmm{bands(4)}.mu;
            gmm_sigma(:,:,4) = gmm{bands(4)}.Sigma;
            gmm_mu(:,5) = gmm{bands(5)}.mu;
            gmm_sigma(:,:,5) = gmm{bands(5)}.Sigma;
        case 6
            gmm_mu(:,3) = gmm{bands(3)}.mu;
            gmm_sigma(:,:,3) = gmm{bands(3)}.Sigma;
            gmm_mu(:,4) = gmm{bands(4)}.mu;
            gmm_sigma(:,:,4) = gmm{bands(4)}.Sigma;
            gmm_mu(:,5) = gmm{bands(5)}.mu;
            gmm_sigma(:,:,5) = gmm{bands(5)}.Sigma;
            gmm_mu(:,6) = gmm{bands(6)}.mu;
            gmm_sigma(:,:,6) = gmm{bands(6)}.Sigma;
        otherwise
            disp('error');
    end
end

end