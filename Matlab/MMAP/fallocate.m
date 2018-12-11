function success = fallocate(file, size)
%fallocate allocates a file 'file' of size 'size' (bytes)

cmd = sprintf('fallocate -l %d "%s"', size, file);
fprintf('running: %s\n', cmd);
[status, cmdout] = unix(cmd);

success = ~logical(status);

if ~success
    error('%s', cmdout) % can not allocate on NTFS
    % please run: "fallocate -l size file"
    % with size = sizeof * x * y * z * t
    % if you are working on sshfs, please connect to the distant worker and
    % run the command (not recommanded)
    % when working with large files, it's better on local ssd !!
end


end

