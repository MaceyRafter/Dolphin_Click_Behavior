clearvars
% Load old and new false detection files
oldFileName = 'I:\Macey_GOM\DT05_TPWS\GofMX_DT05_disk03_Delphin_FD1_kf.mat';
newFileName = 'I:\Macey_GOM\DT05_TPWS\GofMX_DT05_disk03_Delphin_FD1.mat';
falseDetOld = load(oldFileName);
falseDetNew = load(newFileName);

% Find all the things that are in both sets
FDinBoth = intersect(falseDetOld.zFD, falseDetNew.zFD);

% Find all the things in old only
FDinOldOnly = setdiff(falseDetOld.zFD, falseDetNew.zFD);

% Find all the things in new only
FDinNewOnly = setdiff(falseDetNew.zFD, falseDetOld.zFD);

% Add color index to each set
FDinBoth = [FDinBoth,6*ones(size(FDinBoth))];
FDinOldOnly = [FDinOldOnly,1*ones(size(FDinOldOnly))]; 
FDinNewOnly = [FDinNewOnly,3*ones(size(FDinNewOnly))];

% Concatonnate vectors
zID = [FDinBoth;FDinOldOnly;FDinNewOnly];

outFileName = strrep(newFileName,'FD1','ID1');
save(outFileName,'zID')

% Write out number of agreements / disagreements
disp(sprintf('# of agreements: %d (%0.2f%%)',length(FDinBoth), 100*length(FDinBoth)/length(zID)))
disp(sprintf('# of disagreements: %d',length(FDinOldOnly)+length(FDinNewOnly)))
disp(sprintf('# of disagreements: %d',length(FDinOldOnly)+length(FDinNewOnly)))
