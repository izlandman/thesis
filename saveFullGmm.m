% a 'wrapper' of sorts to allow _buildOneGmm_ to be called repeadtedly to
% generate the saved data of band specific models

% INPUTS: SUBJECTS are the unique subject integer values of the files to be
% generated, can be single characters or a long list. BANDS are similar in
% that they can be one value or a vector.

% OUTPUTS: the resultant models are saved in the folder called FULL GMM.
% This does not make the folder, nor does it handle housekeeping of the
% data, as it was assumed this would only need to be run once.

function saveFullGmm(subjects,bands)

for b=1:length(bands)
    for i=1:length(subjects)
        
        full = buildOneGmm(subjects(i),bands(b));
        
        gm_save = strcat('Full GMM\','subject',num2str(subjects(i)),'band',num2str(bands(b)),'.mat');
        save(gm_save,'full');
        
    end
end

end