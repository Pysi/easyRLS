function clean(F)
%clean deletes unnecessary files to save space

% raw
% rawRAS
% baseline

delete(fullfile(F.dir.files, 'raw*')); % raw and rawRAS files
rmdir(fullfile(F.dir.IP, 'baseline'), 's'); % baseline