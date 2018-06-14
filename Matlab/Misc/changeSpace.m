function changeSpace(F, tag, outMode)
%changeSpace changes the space in the matfile for the given tag

copyfile( [F.tag(tag) '.mat'], [F.tag(tag) '_old.mat']); % backup

infoFile = matfile( [F.tag(tag) '.mat'], 'Writable', true); % open writable

infoFile.space = outMode; % change mode

end