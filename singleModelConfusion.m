% haven't sorted out where this is used yet, but odds are it isn't that
% important anymore (24 april 2015)

function [epoch_confusion_euclidean, epoch_confusion_mahal] = ...
    singleModelConfusion(epoch_models,gmm_models,gmm_mus,gm_index,number_of_epochs)

% setup constants
epoch_num_files = length(epoch_models);
gmm_num_files = length(gmm_models);
epoch_confusion_euclidean = zeros(epoch_num_files,epoch_num_files);
epoch_confusion_mahal = zeros(epoch_num_files,epoch_num_files);

for k=1:epoch_num_files;
    
    % mahal holder
    mahal_distance = 1000*ones(epoch_num_files,number_of_epochs(k));
    
    for r=1:gmm_num_files
        
        mahal_distance(gm_index(r),:) = ...
            log10(mahal(gmdistribution(gmm_models{r,1},gmm_models{r,2}),...
            squeeze(epoch_models{k}(:,2,:))'));
    
    end
    
    [~,min_index_mahal] = min(mahal_distance(gm_index,:));
    
    for n=1:number_of_epochs(k)
        
        euclidean_distance = pdist( [squeeze(epoch_models{k}(:,2,n))';gmm_mus] );
        
        [~,min_index] = min(euclidean_distance(1:epoch_num_files),[],2);
        
        epoch_confusion_euclidean(k,min_index) = ...
            epoch_confusion_euclidean(k,min_index) + 1;
        
        epoch_confusion_mahal(k,min_index_mahal(n)) = ...
            epoch_confusion_mahal(k,min_index_mahal(n)) + 1;
        
    end
    
end

end