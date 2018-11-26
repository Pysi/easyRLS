function success = fallocate(file, size)
%fallocate allocates a file 'file' of size 'size' (bytes)

cmd = sprintf('fallocate -l %d "%s"', size, file);
[status, cmdout] = unix(cmd);

success = ~logical(status);

if ~success
    error('%s', cmdout) % can not allocate on NTFS
end


end

