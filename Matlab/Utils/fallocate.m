function success = fallocate(file, size)
%fallocate allocates a file 'file' of size 'size' (bytes)

cmd = sprintf('fallocate -l %d "%s"', size, file);
[status, cmdout] = unix(cmd);

success = logical(status);

if status
    error('Failed to allocate file (is it NTFS ?)\n\t%s', cmdout)
end


end

