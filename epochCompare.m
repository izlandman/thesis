% This attempts to find the shortest distances between epochs across an
% entire trial outside of the native subject

% INPUTS: string '' of the folder containing the epoch directory in
% question

% OUTPUTS: 4D matrix of epochs x subjects x bands x three data types. the
% three daya types are (1) the distance (2) the epoch (3) the subject

% Overall the reults are poorly organized and this doesn't shed any light
% that isn't already learned from the confusion matrix

function [final_distances] = epochCompare(epoch_directory)

close all;

% important epoch.mat files
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
for i=1:epoch_num_files
    epoch_models(i) = load(epoch_file_list{i});
    number_of_epochs(i) = length(epoch_models(i).epochs(1,1,1,:));
end

[a,a,bands,a] = size(epoch_models(1,1).epochs);

y = 2;
x = 1;
b = 1;

% store three values (distance, epoch, 
final_distances = 1985*ones(max(number_of_epochs),epoch_num_files,bands,3);

for y=1:epoch_num_files
    for x=y+1:epoch_num_files
        for b=1:bands
        
            distances = pdist( [ squeeze(epoch_models(1,y).epochs(:,2,b,:))';...
                squeeze(epoch_models(1,x).epochs(:,2,b,:))'] );
            % square it out
            square_distance = squareform(distances);
            % take the entire column, but half the rows
            inter_distances = square_distance(number_of_epochs(y)+1:end,1:number_of_epochs(y));
            % finds minimum compared to non-native epochs
            [values,indexes] = min(inter_distances);
            if( sum( values==0 ) > 0 )
                disp('zeroes');
            end
            % update each dimension if the distances values are LESS THAN
            % what is presently stored. this will result in a compact
            % matrix with stored distance, epoch, and subject
            
            % store distance
            dist_values = final_distances(1:number_of_epochs(y),y,b,1);
            
            % store epoch
            epoch_values = final_distances(1:number_of_epochs(y),y,b,2);
            epoch_values( dist_values > values' ) = indexes( dist_values > values' );
            final_distances(1:number_of_epochs(y),y,b,2) = epoch_values;
            
            % store subject
            subject_values = final_distances(1:number_of_epochs(y),y,b,3);
            subject_map = repmat(x,number_of_epochs(y),1);
            subject_values( dist_values > values' ) = subject_map( dist_values > values' );
            final_distances(1:number_of_epochs(y),y,b,3) = subject_values;
            
            % write distances into matrix
            dist_values( dist_values > values' ) = values( dist_values > values' );
            final_distances(1:number_of_epochs(y),y,b,1) = dist_values;

        end
    end
end

end