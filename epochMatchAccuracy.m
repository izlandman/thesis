% randomly take subjects and match them against their GMMs

% INPUTS: input the number of simulation trials to run

% OUTPUTS: ACC_EUC & ACC_MAH are vectors of length TRIALS that show the
% true accuracy of the random trials. R1 & R2 are the match results from
% _matchEpochToGmm_ and RAND_SUBJECTS_ shows the randomly chosen subjects.

% DEPENDENCIES: _matchEpochToGmm_, _folderFinder_, and _fileFinderFull are
% required for this to run along with local function _getEpochFile_

% in mininal trials, up to 10.. the results are VERY POOR

function [acc_euc,acc_mah,r1,r2,rand_subjects] = epochMatchAccuracy(trials)

r1 = zeros(2,6,trials);
r2 = zeros(2,6,trials);
acc_euc = zeros(trials,1);
acc_mah = zeros(trials,1);

rand_subjects = randi(109,trials,1);
rand_trials = randi(14,trials,1);

for r=1:trials
    
    match_epoch = getEpochFile(rand_subjects(r),rand_trials(r));
    match_epoch = match_epoch{1};
    
    for b=1:6
        [r1(:,b,r),r2(:,b,r)] = matchEpochToGmm(match_epoch,b);
    end
    
    acc_euc(r) = mean( r1(1,:,r) == rand_subjects(r) );
    acc_mah(r) = mean( r2(1,:,r) == rand_subjects(r) );
    
end

end

function return_file = getEpochFile(subject,trial)

if( trial < 15 && trial > 2 )
    target_name = ['_',num2str(trial),'_epoch'];
elseif( trial == 1 )
    target_name = 'REC_epoch';
elseif( trial == 2 )
    target_name = 'REO_epoch';
else
    disp('error in trial match');
end

target_folder = folderFinder(pwd,target_name);

return_file = fileFinderFull(target_folder,subject);

end