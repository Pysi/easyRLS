function rescalestack(inPathTag,outPathTag, factor)
% resize a stack by factor

    m = Mmap(inPathTag);

    fid = fopen([outPathTag '.bin'], 'wb');

    x = ceil(m.x*factor);
    y = ceil(m.y*factor);

    writeINFO([outPathTag '.mat'], x, y, m.z, m.t, m.Z, m.T, m.space, m.pixtype)

    for it = m.T
        for iz = m.Z
            img = imresize(m(:,:,iz,it), [x y]);
            fwrite(fid, img, m.pixtype);
        end
        disp(it);
    end

    fclose(fid);

end
        